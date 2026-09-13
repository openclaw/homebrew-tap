#!/usr/bin/env python3
"""Update a Homebrew formula and optional cask for a GitHub release.

The script keeps formula-specific editing in this tap. It supports the simple
single `url`/`sha256` formula shape as well as formulae with separate
`on_macos` and `on_linux` stanzas such as `Formula/wacli.rb`. It can also
update a matching cask when a release publishes both CLI and app assets.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import pathlib
import re
import string
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request


sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import formula_text


USER_AGENT = "steipete-homebrew-tap-updater"
DOWNLOAD_TIMEOUT_SECONDS = 30
GIT_NETWORK_TIMEOUT_SECONDS = 60
TAP_TOKEN_PATTERN = re.compile(r"[a-z0-9][a-z0-9+@._-]*")
REPOSITORY_PATTERN = re.compile(r"[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9][A-Za-z0-9_.-]*")
RELEASE_TAG_PATTERN = re.compile(r"v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?")
ARTIFACT_TOKEN_PATTERN = re.compile(r"[A-Za-z0-9][A-Za-z0-9+@._-]*")
SHA256_PATTERN = re.compile(r"[0-9a-f]{64}")
GIT_OBJECT_PATTERN = re.compile(r"[0-9a-f]{40}")
REQUEST_ID_PATTERN = re.compile(r"[A-Za-z0-9][-A-Za-z0-9._:]{0,127}")
RELEASE_TARGETS = formula_text.RELEASE_TARGETS
CANONICAL_TARGETS = frozenset(("darwin_universal", *RELEASE_TARGETS))
TEMPLATE_FIELDS = frozenset(("formula", "version", "tag", "target"))


def is_crabbox_formula(path: pathlib.Path) -> bool:
    crabbox = pathlib.Path("Formula/crabbox.rb")
    return path.resolve() == crabbox.resolve() or (
        path.exists() and crabbox.exists() and path.samefile(crabbox)
    )


def validate_tap_token(value: str, description: str) -> str:
    if not TAP_TOKEN_PATTERN.fullmatch(value):
        raise SystemExit(f"invalid {description} {value!r}; expected a Homebrew-safe token")
    return value


def validate_repository(value: str) -> str:
    if not REPOSITORY_PATTERN.fullmatch(value):
        raise SystemExit(f"invalid repository {value!r}; expected owner/repo")
    return value


def validate_release_tag(value: str) -> str:
    if not RELEASE_TAG_PATTERN.fullmatch(value):
        raise SystemExit(f"invalid release tag {value!r}; expected a semantic version such as v1.2.3")
    return value


def validate_template(value: str, description: str, allowed_fields: frozenset[str] = TEMPLATE_FIELDS) -> str:
    try:
        parsed = tuple(string.Formatter().parse(value))
    except ValueError as error:
        raise SystemExit(f"invalid {description}: {error}") from error

    for _, field_name, format_spec, conversion in parsed:
        if field_name is None:
            continue
        if field_name not in allowed_fields or format_spec or conversion:
            raise SystemExit(f"invalid {description} placeholder {field_name!r}")
    return value


def validate_artifact_token(value: str, description: str) -> str:
    if not ARTIFACT_TOKEN_PATTERN.fullmatch(value):
        raise SystemExit(f"invalid {description} {value!r}; expected a release asset filename")
    return value


def validate_sha256(value: str, description: str) -> str:
    if not SHA256_PATTERN.fullmatch(value):
        raise SystemExit(f"invalid {description}; expected 64 lowercase hexadecimal characters")
    return value


def validate_git_object(value: str, description: str) -> str:
    if not GIT_OBJECT_PATTERN.fullmatch(value):
        raise SystemExit(f"invalid {description}; expected a 40-character lowercase Git object ID")
    return value


def validate_request_id(value: str) -> str:
    if not REQUEST_ID_PATTERN.fullmatch(value):
        raise SystemExit(
            "invalid request ID; expected 1-128 ASCII letters, digits, hyphens, dots, underscores, or colons"
        )
    return value


def parse_explicit_assets(value: str | None) -> dict[str, dict[str, str]] | None:
    if not value:
        return None
    try:
        payload = json.loads(value)
    except json.JSONDecodeError as error:
        raise SystemExit(f"invalid assets JSON: {error.msg}") from error
    if not isinstance(payload, dict) or set(payload) != set(RELEASE_TARGETS):
        raise SystemExit("assets JSON must contain exactly darwin_amd64, darwin_arm64, linux_amd64, and linux_arm64")

    assets: dict[str, dict[str, str]] = {}
    names: set[str] = set()
    for target in RELEASE_TARGETS:
        item = payload[target]
        if not isinstance(item, dict) or set(item) != {"name", "sha256"}:
            raise SystemExit(f"assets JSON {target} must contain exactly name and sha256")
        name = item["name"]
        digest = item["sha256"]
        if not isinstance(name, str) or not name.endswith(".tar.gz"):
            raise SystemExit(f"assets JSON {target} has an unsafe release asset filename")
        validate_artifact_token(name, f"assets JSON {target} filename")
        if not isinstance(digest, str):
            raise SystemExit(f"assets JSON {target} has an invalid SHA-256")
        validate_sha256(digest, f"assets JSON {target}")
        if name in names:
            raise SystemExit(f"assets JSON repeats release asset filename {name!r}")
        names.add(name)
        assets[target] = {"name": name, "sha256": digest}
    return assets


def explicit_asset_url(repository: str, tag: str, name: str) -> str:
    return validate_url(
        f"https://github.com/{repository}/releases/download/{tag}/{name}",
        "explicit release asset URL",
    )


def verify_explicit_assets(repository: str, tag: str, assets: dict[str, dict[str, str]]) -> None:
    for target in RELEASE_TARGETS:
        item = assets[target]
        url = explicit_asset_url(repository, tag, item["name"])
        observed = sha256(url)
        if observed != item["sha256"]:
            raise SystemExit(
                f"downloaded {target} SHA-256 mismatch: observed {observed}, expected {item['sha256']}"
            )
        print(f"verified {target}: {observed}  {url}")


def validate_url(value: str, description: str) -> str:
    if any(character.isspace() or ord(character) < 32 for character in value):
        raise SystemExit(f"invalid {description}; whitespace and control characters are not allowed")
    if '"' in value or "\\" in value or "#{" in value:
        raise SystemExit(f"invalid {description}; unsafe Ruby string characters are not allowed")
    parsed = urllib.parse.urlsplit(value)
    if parsed.scheme != "https" or not parsed.hostname or parsed.username or parsed.password or parsed.fragment:
        raise SystemExit(f"invalid {description} {value!r}; expected an HTTPS URL without credentials or fragments")
    return value


def tap_path(directory: str, token: str) -> pathlib.Path:
    relative = pathlib.Path(directory) / f"{token}.rb"
    expected_parent = (pathlib.Path.cwd() / directory).resolve()
    if (pathlib.Path.cwd() / relative).resolve().parent != expected_parent:
        raise SystemExit(f"invalid {directory} path for {token!r}")
    return relative


class DownloadRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        # urllib resolves relative Locations before this hook, but has not followed them yet.
        try:
            validate_url(newurl, "redirected download URL")
        except SystemExit:
            fp.close()
            raise
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def sha256(url: str) -> str:
    validate_url(url, "download URL")
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    digest = hashlib.sha256()
    opener = urllib.request.build_opener(DownloadRedirectHandler())
    try:
        with opener.open(request, timeout=DOWNLOAD_TIMEOUT_SECONDS) as response:
            while chunk := response.read(1024 * 1024):
                digest.update(chunk)
    except TimeoutError as error:
        raise SystemExit(f"timed out downloading {url} after {DOWNLOAD_TIMEOUT_SECONDS}s") from error
    except urllib.error.URLError as error:
        if isinstance(error.reason, TimeoutError):
            raise SystemExit(f"timed out downloading {url} after {DOWNLOAD_TIMEOUT_SECONDS}s") from error
        raise
    return digest.hexdigest()


def validate_verified_hash_contract(
    hashes: dict[str, str | None],
    source_tag_commit: str | None,
    source_tag_object: str | None,
    request_id: str | None,
) -> dict[str, str] | None:
    supplied = (*hashes.values(), source_tag_commit, source_tag_object)
    if not any(supplied):
        return None

    missing = [target + "_sha256" for target in RELEASE_TARGETS if not hashes.get(target)]
    if not source_tag_commit:
        missing.append("source_tag_commit")
    if not source_tag_object:
        missing.append("source_tag_object")
    if not request_id:
        missing.append("request_id")
    if missing:
        raise SystemExit("verified-hash mode requires all inputs; missing " + ", ".join(missing))

    validated = {
        target: validate_sha256(hashes[target] or "", target + " SHA-256")
        for target in RELEASE_TARGETS
    }
    commit = validate_git_object(source_tag_commit, "source tag commit")
    tag_object = validate_git_object(source_tag_object, "source tag object")
    validate_request_id(request_id)
    if commit == tag_object:
        raise SystemExit("source tag object must identify an annotated tag, not the peeled commit")
    return validated


def validate_source_tag_refs(
    output: str,
    tag: str,
    source_tag_object: str,
    source_tag_commit: str,
) -> None:
    expected_ref = f"refs/tags/{tag}"
    expected_peeled_ref = f"{expected_ref}^{{}}"
    refs: dict[str, str] = {}
    for line in output.splitlines():
        fields = line.split("\t")
        if len(fields) != 2 or fields[1] in refs:
            raise SystemExit("source tag lookup returned an invalid or duplicate ref")
        refs[fields[1]] = fields[0]
    if refs != {
        expected_ref: source_tag_object,
        expected_peeled_ref: source_tag_commit,
    }:
        raise SystemExit("live source tag does not match the supplied annotated tag object and peeled commit")


def verify_remote_source_tag(
    repository: str,
    tag: str,
    source_tag_object: str,
    source_tag_commit: str,
) -> None:
    source_url = f"https://github.com/{repository}.git"
    ref = f"refs/tags/{tag}"
    environment = {
        "GIT_CONFIG_GLOBAL": "/dev/null",
        "GIT_CONFIG_NOSYSTEM": "1",
        "GIT_TERMINAL_PROMPT": "0",
        "HOME": "/",
        "LC_ALL": "C",
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
    }

    def git(command: list[str], failure: str, *, timeout: float | None = None) -> str:
        try:
            completed = subprocess.run(
                command,
                cwd="/",
                env=environment,
                check=False,
                capture_output=True,
                text=True,
                timeout=timeout,
            )
        except subprocess.TimeoutExpired as error:
            raise SystemExit(f"{failure}: timed out after {GIT_NETWORK_TIMEOUT_SECONDS}s") from error
        if completed.returncode != 0:
            detail = completed.stderr.strip() or failure
            raise SystemExit(f"{failure}: {detail}")
        return completed.stdout.strip()

    with tempfile.TemporaryDirectory(prefix="tap-source-tag-") as directory:
        git(["git", "init", "--bare", "--quiet", directory], "failed to initialize source tag check")
        git(
            [
                "git",
                "-C",
                directory,
                "fetch",
                "--quiet",
                "--no-tags",
                "--depth=1",
                source_url,
                f"{ref}:{ref}",
            ],
            "failed to fetch live source tag",
            timeout=GIT_NETWORK_TIMEOUT_SECONDS,
        )
        fetched_tag_object = git(
            ["git", "-C", directory, "rev-parse", "--verify", f"{ref}^{{tag}}"],
            "live source ref is not an annotated tag",
        )
        fetched_tag_commit = git(
            ["git", "-C", directory, "rev-parse", "--verify", f"{ref}^{{commit}}"],
            "live source tag does not peel to a commit",
        )

    if fetched_tag_object != source_tag_object or fetched_tag_commit != source_tag_commit:
        raise SystemExit("fetched source tag does not match the supplied annotated tag object and commit")

    output = git(
        ["git", "ls-remote", "--tags", source_url, ref, f"{ref}^{{}}"],
        "failed to read live source tag",
        timeout=GIT_NETWORK_TIMEOUT_SECONDS,
    )
    validate_source_tag_refs(output, tag, source_tag_object, source_tag_commit)


def format_template(value: str, formula: str, version: str, tag: str, target: str | None = None) -> str:
    replacements = {
        "formula": formula,
        "version": version,
        "tag": tag,
    }
    if target is not None:
        replacements["target"] = target
    return value.format(**replacements)


def require_template_field(value: str, field: str, description: str) -> None:
    occurrences = sum(1 for _, name, _, _ in string.Formatter().parse(value) if name == field)
    if occurrences != 1:
        raise SystemExit(f"{description} must contain exactly one {{{field}}} placeholder")


def parse_target_aliases(value: str | None) -> dict[str, str]:
    if not value:
        return {}

    aliases: dict[str, str] = {}
    for item in value.split(","):
        if not item:
            continue
        if "=" not in item:
            raise SystemExit(f"invalid target alias {item!r}; expected canonical=artifact-target")
        canonical, artifact_target = item.split("=", 1)
        canonical = canonical.strip()
        artifact_target = artifact_target.strip()
        if canonical not in CANONICAL_TARGETS:
            raise SystemExit(f"invalid canonical target {canonical!r}")
        if canonical in aliases:
            raise SystemExit(f"duplicate canonical target {canonical!r}")
        aliases[canonical] = validate_artifact_token(artifact_target, f"alias for {canonical}")
    resolved_targets = [aliases.get(target, target) for target in RELEASE_TARGETS]
    if len(set(resolved_targets)) != len(resolved_targets):
        raise SystemExit("target aliases must resolve the four release targets to distinct artifact names")
    return aliases


def prepare_cask_update(cask: str, repository: str, tag: str, artifact: str) -> tuple[pathlib.Path, str]:
    validate_artifact_token(artifact, "cask artifact")
    version = tag[1:] if tag.startswith("v") else tag
    url = f"https://github.com/{repository}/releases/download/{tag}/{artifact}"
    path = tap_path("Casks", cask)
    if not path.exists():
        raise SystemExit(f"{path} does not exist; cask creation needs a manual template")

    text = path.read_text()
    digest = sha256(url)
    text = formula_text.update_version(text, version)
    text = formula_text.update_top_level_url_and_sha(text, url, digest, version)
    print(f"cask: {digest}  {url}")
    return path, text


def write_formula_and_cask(
    path: pathlib.Path,
    text: str,
    repository: str,
    tag: str,
    cask: str | None,
    cask_artifact: str | None,
) -> None:
    updates = [(path, text)]
    if cask:
        assert cask_artifact is not None
        updates.append(prepare_cask_update(cask, repository, tag, cask_artifact))

    # Complete downloads and rendering for both files before changing either one.
    for target, content in updates:
        target.write_text(content)
    if cask:
        print(f"updated {updates[1][0]} to {tag.removeprefix('v')}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--formula", required=True, help="Formula name, e.g. wacli")
    parser.add_argument("--tag", required=True, help="Release tag, e.g. v0.7.0")
    parser.add_argument("--repository", required=True, help="Source repository, e.g. steipete/wacli")
    parser.add_argument("--assets-json", help="Exact four-platform asset name/SHA-256 JSON")
    parser.add_argument(
        "--description",
        help="Formula description used when creating a missing formula",
    )
    parser.add_argument(
        "--macos-artifact",
        help="macOS release artifact name. Defaults to <formula>-macos-universal.tar.gz",
    )
    parser.add_argument(
        "--linux-url",
        help="Linux source/archive URL. Defaults to the GitHub tag archive",
    )
    parser.add_argument(
        "--artifact-template",
        help=(
            "Release asset template for multi-architecture formulae. "
            "Supports {formula}, {version}, {tag}, and {target}; "
            "defaults to {formula}_{version}_{target}.tar.gz when the formula has per-target URLs."
        ),
    )
    parser.add_argument(
        "--artifact-url",
        help=(
            "Direct top-level artifact/source URL. Supports {formula}, {version}, and {tag}. "
            "Useful for npm tarballs and source archives."
        ),
    )
    parser.add_argument(
        "--target-aliases",
        help=(
            "Comma-separated canonical=artifact-target aliases for custom asset names, "
            "for example darwin_arm64=macos-arm64,linux_amd64=linux-x86_64."
        ),
    )
    parser.add_argument("--darwin-amd64-sha256", help="Verified Darwin amd64 archive SHA-256")
    parser.add_argument("--darwin-arm64-sha256", help="Verified Darwin arm64 archive SHA-256")
    parser.add_argument("--linux-amd64-sha256", help="Verified Linux amd64 archive SHA-256")
    parser.add_argument("--linux-arm64-sha256", help="Verified Linux arm64 archive SHA-256")
    parser.add_argument("--source-tag-commit", help="Peeled commit of the verified annotated source tag")
    parser.add_argument("--source-tag-object", help="Object ID of the verified annotated source tag")
    parser.add_argument("--request-id", help="Unique caller-generated verified-handoff identifier")
    parser.add_argument(
        "--verify-source-tag-only",
        action="store_true",
        help="Revalidate verified-hash source provenance without changing a formula",
    )
    parser.add_argument("--cask", help="Optional cask name to update alongside the formula")
    parser.add_argument(
        "--cask-artifact",
        help=(
            "Release asset name for --cask. Supports {formula}, {version}, and {tag}; "
            "required when --cask is set."
        ),
    )
    args = parser.parse_args(argv)

    args.formula = validate_tap_token(args.formula, "formula")
    args.repository = validate_repository(args.repository)
    args.tag = validate_release_tag(args.tag)
    if args.cask:
        args.cask = validate_tap_token(args.cask, "cask")
    if args.macos_artifact:
        validate_artifact_token(args.macos_artifact, "macOS artifact")
    if args.linux_url:
        validate_url(args.linux_url, "Linux URL")
    if args.artifact_template:
        validate_template(args.artifact_template, "artifact template")
    if args.artifact_url:
        validate_template(args.artifact_url, "artifact URL template", frozenset(("formula", "version", "tag")))
    if args.cask_artifact:
        validate_template(args.cask_artifact, "cask artifact template", frozenset(("formula", "version", "tag")))
    explicit_assets = parse_explicit_assets(args.assets_json)

    verified_hashes = validate_verified_hash_contract(
        {
            "darwin_amd64": args.darwin_amd64_sha256,
            "darwin_arm64": args.darwin_arm64_sha256,
            "linux_amd64": args.linux_amd64_sha256,
            "linux_arm64": args.linux_arm64_sha256,
        },
        args.source_tag_commit,
        args.source_tag_object,
        args.request_id,
    )
    if verified_hashes is not None:
        if not args.verify_source_tag_only:
            paths = [tap_path("Formula", args.formula)]
            if args.cask:
                paths.append(tap_path("Casks", args.cask))
            if any(is_crabbox_formula(path) for path in paths):
                raise SystemExit(
                    "Crabbox requires ordinary assets with public downloads, not verified-hashes-v1; "
                    "use --assets-json after publication: https://github.com/openclaw/crabbox/blob/main/docs/RELEASING.md"
                )
        incompatible = [
            option
            for option, value in (
                ("macos_artifact", args.macos_artifact),
                ("linux_url", args.linux_url),
                ("artifact_url", args.artifact_url),
                ("cask", args.cask),
                ("cask_artifact", args.cask_artifact),
            )
            if value
        ]
        if incompatible:
            raise SystemExit(
                "verified-hash mode does not support these legacy inputs: " + ", ".join(incompatible)
            )
        if not args.artifact_template:
            raise SystemExit("verified-hash mode requires an explicit artifact_template")
        require_template_field(args.artifact_template, "target", "verified artifact template")
    elif args.verify_source_tag_only:
        raise SystemExit("--verify-source-tag-only requires the complete verified-hash input set")
    if explicit_assets is not None:
        incompatible = [
            option
            for option, value in (
                ("artifact_template", args.artifact_template),
                ("artifact_url", args.artifact_url),
                ("linux_url", args.linux_url),
                ("macos_artifact", args.macos_artifact),
                ("target_aliases", args.target_aliases),
                ("verified_hashes", verified_hashes),
                ("source_tag_commit", args.source_tag_commit),
                ("source_tag_object", args.source_tag_object),
            )
            if value
        ]
        if incompatible:
            raise SystemExit("explicit-assets mode does not support other artifact contracts: " + ", ".join(incompatible))

    version = args.tag[1:] if args.tag.startswith("v") else args.tag
    if args.cask and not args.cask_artifact:
        raise SystemExit("--cask-artifact is required when --cask is set")
    cask_artifact = None
    if args.cask_artifact:
        cask_artifact = format_template(args.cask_artifact, args.formula, version, args.tag)
        validate_artifact_token(cask_artifact, "cask artifact")
    target_aliases = parse_target_aliases(args.target_aliases)
    if args.artifact_template:
        for target in RELEASE_TARGETS:
            artifact_target = target_aliases.get(target, target)
            artifact = format_template(
                args.artifact_template,
                args.formula,
                version,
                args.tag,
                artifact_target,
            )
            validate_artifact_token(artifact, f"artifact for {target}")

    if verified_hashes is not None:
        assert args.source_tag_object is not None
        assert args.source_tag_commit is not None
        assert args.artifact_template is not None
        verify_remote_source_tag(
            args.repository,
            args.tag,
            args.source_tag_object,
            args.source_tag_commit,
        )
        if args.verify_source_tag_only:
            print(
                "verified live source tag "
                f"{args.repository}@{args.tag} object={args.source_tag_object} commit={args.source_tag_commit}"
            )
            return 0

        path = tap_path("Formula", args.formula)
        if not path.exists():
            raise SystemExit("verified-hash mode updates existing formulae only")
        text = formula_text.render_verified_target_formula(
            path.read_text(),
            args.repository,
            args.tag,
            args.formula,
            version,
            args.artifact_template,
            target_aliases,
            verified_hashes,
        )
        path.write_text(text)
        print(f"updated {path} to {version} from caller-verified target hashes")
        return 0

    if explicit_assets is not None:
        path = tap_path("Formula", args.formula)
        if path.exists():
            text = path.read_text()
        else:
            description = args.description or f"{args.formula} command-line tool"
            text = formula_text.seed_formula(
                args.formula,
                args.repository,
                version,
                description,
                "{formula}_{version}_{target}.tar.gz",
            )
        verify_explicit_assets(args.repository, args.tag, explicit_assets)
        text = formula_text.render_explicit_target_formula(
            text,
            args.repository,
            version,
            {
                target: (explicit_asset_url(args.repository, args.tag, item["name"]), item["sha256"])
                for target, item in explicit_assets.items()
            },
        )
        write_formula_and_cask(path, text, args.repository, args.tag, args.cask, cask_artifact)
        print(f"updated {path} to {version} from exact verified release assets")
        return 0

    macos_artifact = args.macos_artifact or f"{args.formula}-macos-universal.tar.gz"
    validate_artifact_token(macos_artifact, "macOS artifact")
    macos_url = (
        format_template(args.artifact_url, args.formula, version, args.tag)
        if args.artifact_url
        else f"https://github.com/{args.repository}/releases/download/{args.tag}/{macos_artifact}"
    )
    linux_url = args.linux_url or f"https://github.com/{args.repository}/archive/refs/tags/{args.tag}.tar.gz"
    validate_url(macos_url, "macOS URL")
    validate_url(linux_url, "Linux URL")

    path = tap_path("Formula", args.formula)
    created = False
    if path.exists():
        text = path.read_text()
    else:
        template = args.artifact_template or "{formula}_{version}_{target}.tar.gz"
        description = args.description or f"{args.formula} command-line tool"
        text = formula_text.seed_formula(args.formula, args.repository, version, description, template)
        created = True
    text = formula_text.update_repository_metadata(text, args.repository)
    text = formula_text.update_version(text, version)
    has_macos = formula_text.has_stanza(text, "on_macos")
    has_linux = formula_text.has_stanza(text, "on_linux")
    url_sha_pairs = formula_text.iter_primary_url_sha_pairs(text)
    classified_pairs = [(match, formula_text.classify_target(match.group("url"), target_aliases, version)) for match in url_sha_pairs]
    target_url_count = sum(1 for _, target in classified_pairs if target)
    has_target_urls = target_url_count > 1 and not formula_text.uses_stanza_url_mode(text, version)
    if args.artifact_template and not has_target_urls and formula_text.uses_stanza_url_mode(text, version):
        text = formula_text.convert_stanza_url_mode_to_targets(
            text,
            args.repository,
            args.tag,
            args.formula,
            version,
            args.artifact_template,
            target_aliases,
        )
        url_sha_pairs = formula_text.iter_primary_url_sha_pairs(text)
        classified_pairs = [(match, formula_text.classify_target(match.group("url"), target_aliases, version)) for match in url_sha_pairs]
        target_url_count = sum(1 for _, target in classified_pairs if target)
        has_target_urls = target_url_count > 1
    elif args.artifact_template and not has_target_urls:
        text = formula_text.insert_target_stanzas(
            text,
            args.repository,
            args.tag,
            args.formula,
            version,
            args.artifact_template,
            target_aliases,
        )
        url_sha_pairs = formula_text.iter_primary_url_sha_pairs(text)
        classified_pairs = [(match, formula_text.classify_target(match.group("url"), target_aliases, version)) for match in url_sha_pairs]
        target_url_count = sum(1 for _, target in classified_pairs if target)
        has_target_urls = target_url_count > 1
    if has_macos != has_linux and not has_target_urls:
        raise SystemExit("formulae with only one platform stanza need manual updates")

    if has_target_urls:
        archives = [
            match for match, _ in classified_pairs
            if re.fullmatch(r'https://github\.com/[^"\n]+/archive/refs/tags/[^"\n]+', match.group("url"))
        ]
        if args.linux_url and len(archives) > 1:
            raise SystemExit("expected at most one source archive URL/checksum pair")
        for match, target in classified_pairs:
            if target or (args.linux_url and match in archives):
                continue
            raise SystemExit(
                f"unclassified release asset in {path}: {match.group('url')}; "
                "supply --target-aliases for custom target names"
            )
        if target_url_count >= len(RELEASE_TARGETS):
            missing = set(RELEASE_TARGETS) - {target for _, target in classified_pairs}
            if missing:
                raise SystemExit(f"failed to update {sorted(missing)[0]} in {path}")
        template = args.artifact_template or "{formula}_{version}_{target}.tar.gz"
        replacements: list[tuple[int, int, str]] = []
        for match, target in classified_pairs:
            if not target:
                continue
            artifact_target = target_aliases.get(target, target)
            artifact = template.format(
                formula=args.formula,
                version=version,
                tag=args.tag,
                target=artifact_target,
            )
            url = f"https://github.com/{args.repository}/releases/download/{args.tag}/{artifact}"
            digest = sha256(url)
            existing_url = match.group("url")
            replacement_url = url
            if "#{version}" in existing_url and existing_url.replace("#{version}", version) == url:
                replacement_url = existing_url
            replacement = (
                f'{match.group("prefix")}{replacement_url}'
                f'{match.group("middle")}{digest}{match.group("suffix")}'
            )
            replacements.append((match.start(), match.end(), replacement))
            print(f"{target}: {digest}  {url}")
        for start, end, replacement in reversed(replacements):
            text = text[:start] + replacement + text[end:]

        if args.linux_url:
            linux_sha = sha256(linux_url)
            text = formula_text.replace_zero_or_one(
                text,
                r'(?P<prefix>url ")https://github\.com/[^"]+/archive/refs/tags/[^"]+(?P<middle>"\n\s+sha256 ")[0-9a-f]+(?P<suffix>")',
                rf'\g<prefix>{linux_url}\g<middle>{linux_sha}\g<suffix>',
                "source archive url and sha256",
            )
            print(f"Linux source: {linux_sha}  {linux_url}")
    else:
        macos_sha = sha256(macos_url)
        if has_macos:
            text = formula_text.update_url_and_sha_in_stanza(text, "on_macos", macos_url, macos_sha, version)
            linux_sha = sha256(linux_url)
            text = formula_text.update_url_and_sha_in_stanza(text, "on_linux", linux_url, linux_sha, version)
        else:
            text = formula_text.update_top_level_url_and_sha(text, macos_url, macos_sha, version)
            linux_sha = None
        print(f"macOS: {macos_sha}  {macos_url}")
        if linux_sha:
            print(f"Linux: {linux_sha}  {linux_url}")

    write_formula_and_cask(path, text, args.repository, args.tag, args.cask, cask_artifact)
    if created:
        print(f"created {path}")
    print(f"updated {path} to {version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
