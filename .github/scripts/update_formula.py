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
import os
import pathlib
import re
import string
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request


USER_AGENT = "steipete-homebrew-tap-updater"
TAP_TOKEN_PATTERN = re.compile(r"[a-z0-9][a-z0-9+@._-]*")
REPOSITORY_PATTERN = re.compile(r"[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9][A-Za-z0-9_.-]*")
RELEASE_TAG_PATTERN = re.compile(r"v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?")
ARTIFACT_TOKEN_PATTERN = re.compile(r"[A-Za-z0-9][A-Za-z0-9+@._-]*")
SHA256_PATTERN = re.compile(r"[0-9a-f]{64}")
GIT_OBJECT_PATTERN = re.compile(r"[0-9a-f]{40}")
REQUEST_ID_PATTERN = re.compile(r"[A-Za-z0-9][-A-Za-z0-9._:]{0,127}")
RELEASE_TARGETS = ("darwin_amd64", "darwin_arm64", "linux_amd64", "linux_arm64")
CANONICAL_TARGETS = frozenset(("darwin_universal", *RELEASE_TARGETS))
TEMPLATE_FIELDS = frozenset(("formula", "version", "tag", "target"))


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


def ruby_string(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("#{", "\\#{")
        .replace("\r", "\\r")
        .replace("\n", "\\n")
    )
    return f'"{escaped}"'


def sha256(url: str) -> str:
    validate_url(url, "download URL")
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    digest = hashlib.sha256()
    with urllib.request.urlopen(request) as response:
        while chunk := response.read(1024 * 1024):
            digest.update(chunk)
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

    def git(command: list[str], failure: str) -> str:
        completed = subprocess.run(
            command,
            cwd="/",
            env=environment,
            check=False,
            capture_output=True,
            text=True,
        )
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
    )
    validate_source_tag_refs(output, tag, source_tag_object, source_tag_commit)


def replace_once(text: str, pattern: str, replacement: str, description: str) -> str:
    matches = re.findall(pattern, text, flags=re.MULTILINE | re.DOTALL)
    if len(matches) != 1:
        raise SystemExit(f"expected exactly one {description}, found {len(matches)}")
    return re.sub(pattern, replacement, text, count=1, flags=re.MULTILINE | re.DOTALL)


def replace_zero_or_one(text: str, pattern: str, replacement: str, description: str) -> str:
    matches = re.findall(pattern, text, flags=re.MULTILINE | re.DOTALL)
    if len(matches) > 1:
        raise SystemExit(f"expected at most one {description}, found {len(matches)}")
    if not matches:
        print(f"no explicit {description}; leaving it unchanged")
        return text
    return re.sub(pattern, replacement, text, count=1, flags=re.MULTILINE | re.DOTALL)


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


def target_markers(target: str, alias: str | None = None) -> tuple[str, ...]:
    markers = {target, target.replace("_", "-")}
    if target == "darwin_amd64":
        markers.update(("macos-x86_64", "macos-amd64", "darwin-x86_64"))
    elif target == "darwin_arm64":
        markers.update(("macos-arm64", "darwin-aarch64"))
    elif target == "linux_amd64":
        markers.update(("linux-x86_64", "linux-amd64"))
    elif target == "linux_arm64":
        markers.update(("linux-aarch64", "linux-arm64"))
    elif target == "darwin_universal":
        markers.update(("macos-universal", "darwin-universal"))
    if alias:
        markers.add(alias)
    return tuple(sorted(markers, key=len, reverse=True))


def classify_target(url: str, aliases: dict[str, str], version: str) -> str | None:
    expanded = url.replace("#{version}", version)
    for target in ("darwin_universal", "darwin_arm64", "darwin_amd64", "linux_arm64", "linux_amd64"):
        for marker in target_markers(target, aliases.get(target)):
            if marker in expanded:
                return target
    return None


def iter_url_sha_pairs(text: str) -> list[re.Match[str]]:
    return list(
        re.finditer(
            r'(?P<prefix>url ")(?P<url>[^"]+)(?P<middle>"\n\s+sha256 ")(?P<sha>[0-9a-f]+)(?P<suffix>")',
            text,
            flags=re.MULTILINE,
        )
    )


def stanza_body(text: str, stanza: str) -> str | None:
    match = re.search(
        rf'^\s*{stanza}\s+do\s*$\n(?P<body>.*?)(?=^\s*(?:on_macos\s+do|on_linux\s+do|head |def |test do))',
        text,
        flags=re.MULTILINE | re.DOTALL,
    )
    if not match:
        return None
    return match.group("body")


def require_single_sha_in_stanza(text: str, stanza: str) -> None:
    body = stanza_body(text, stanza)
    if body is None:
        return

    checksums = re.findall(r'^\s*sha256\s+"[^"]+"', body, flags=re.MULTILINE)
    if len(checksums) != 1:
        raise SystemExit(
            f"expected exactly one sha256 in {stanza} stanza, found {len(checksums)}; "
            "formulae with multiple architecture-specific checksums need manual updates"
        )


def stanza_url_shape_count(text: str, stanza: str, version: str) -> int:
    body = stanza_body(text, stanza)
    if body is None:
        return 0

    pairs = iter_url_sha_pairs(body)
    return len({pair.group("url").replace("#{version}", version) for pair in pairs})


def uses_stanza_url_mode(text: str, version: str) -> bool:
    if not (has_stanza(text, "on_macos") and has_stanza(text, "on_linux")):
        return False
    return all(stanza_url_shape_count(text, stanza, version) <= 1 for stanza in ("on_macos", "on_linux"))


def stanza_match(text: str, stanza: str) -> re.Match[str] | None:
    return re.search(
        rf'(?P<header>^\s*{stanza}\s+do\s*$\n)(?P<body>.*?)(?=^\s*(?:on_macos\s+do|on_linux\s+do|head |def |test do))',
        text,
        flags=re.MULTILINE | re.DOTALL,
    )


def replace_url_preserving_interpolation(
    text: str,
    pattern: str,
    url: str,
    version: str,
    description: str,
) -> str:
    matches = list(re.finditer(pattern, text, flags=re.MULTILINE | re.DOTALL))
    if len(matches) != 1:
        raise SystemExit(f"expected exactly one {description}, found {len(matches)}")

    match = matches[0]
    existing_url = match.group("url")
    if "#{version}" in existing_url and existing_url.replace("#{version}", version) == url:
        print(f"{description} uses #{{version}} interpolation; leaving it unchanged")
        return text

    return text[: match.start("url")] + url + text[match.end("url") :]


def update_url_and_sha_in_stanza(text: str, stanza: str, url: str, digest: str, version: str) -> str:
    match = stanza_match(text, stanza)
    if not match:
        return text

    body = match.group("body")
    pairs = iter_url_sha_pairs(body)
    if not pairs:
        raise SystemExit(f"expected at least one url/sha256 pair in {stanza} stanza")

    expanded_urls = {pair.group("url").replace("#{version}", version) for pair in pairs}
    if len(expanded_urls) > 1:
        raise SystemExit(
            f"expected one source URL shape in {stanza} stanza, found {len(expanded_urls)}; "
            "formulae with multiple architecture-specific checksums need manual updates"
        )

    replacements: list[tuple[int, int, str]] = []
    for pair in pairs:
        existing_url = pair.group("url")
        replacement_url = url
        if "#{version}" in existing_url and existing_url.replace("#{version}", version) == url:
            replacement_url = existing_url
        replacements.append(
            (
                pair.start(),
                pair.end(),
                f'{pair.group("prefix")}{replacement_url}{pair.group("middle")}{digest}{pair.group("suffix")}',
            )
        )

    for start, end, replacement in reversed(replacements):
        body = body[:start] + replacement + body[end:]

    return text[: match.start("body")] + body + text[match.end("body") :]


def has_stanza(text: str, stanza: str) -> bool:
    return stanza_body(text, stanza) is not None


def ruby_class_name(formula: str) -> str:
    return "".join(part.capitalize() for part in re.split(r"[-_]+", formula) if part)


def seed_formula(formula: str, repository: str, version: str, description: str, template: str) -> str:
    def url(target: str) -> str:
        artifact = template.format(
            formula=formula,
            version="#{version}",
            tag=f"v{version}",
            target=target,
        )
        return f"https://github.com/{repository}/releases/download/v#{{version}}/{artifact}"

    class_name = ruby_class_name(formula)
    return f'''class {class_name} < Formula
  desc {ruby_string(description)}
  homepage "https://github.com/{repository}"
  version "{version}"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "{url("darwin_arm64")}"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    else
      url "{url("darwin_amd64")}"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "{url("linux_arm64")}"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    else
      url "{url("linux_amd64")}"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "{formula}"
  end

  test do
    assert_match version.to_s, shell_output("#{{bin}}/{formula} --version")
  end
end
'''


def target_url(
    repository: str,
    tag: str,
    formula: str,
    version: str,
    template: str,
    target_aliases: dict[str, str],
    target: str,
) -> str:
    artifact_target = target_aliases.get(target, target)
    artifact = template.format(
        formula=formula,
        version=version,
        tag=tag,
        target=artifact_target,
    )
    return f"https://github.com/{repository}/releases/download/{tag}/{artifact}"


def interpolated_target_url(
    repository: str,
    tag: str,
    formula: str,
    version: str,
    template: str,
    target_aliases: dict[str, str],
    target: str,
) -> str:
    artifact_target = target_aliases.get(target, target)
    interpolated_version = "#{version}"
    interpolated_tag = f"v{interpolated_version}" if tag == f"v{version}" else interpolated_version
    artifact = template.format(
        formula=formula,
        version=interpolated_version,
        tag=interpolated_tag,
        target=artifact_target,
    )
    return f"https://github.com/{repository}/releases/download/{interpolated_tag}/{artifact}"


def predicate_architecture(line: str) -> str | None:
    match = re.fullmatch(
        r"    (?:if|elsif) Hardware::CPU\.(arm|intel)\?(?: && Hardware::CPU\.is_64_bit\?)?\n?",
        line,
    )
    if match:
        return "arm64" if match.group(1) == "arm" else "amd64"
    match = re.fullmatch(r"    on_(arm|intel) do\n?", line)
    if match:
        return "arm64" if match.group(1) == "arm" else "amd64"
    return None


def update_verified_stanza(
    text: str,
    stanza: str,
    repository: str,
    tag: str,
    formula: str,
    version: str,
    template: str,
    target_aliases: dict[str, str],
    hashes: dict[str, str],
) -> str:
    matches = list(re.finditer(rf"^  {stanza} do$", text, flags=re.MULTILINE))
    match = stanza_match(text, stanza)
    if len(matches) != 1 or match is None:
        raise SystemExit(f"verified-hash mode requires exactly one {stanza} stanza")

    prefix = "darwin" if stanza == "on_macos" else "linux"
    lines = match.group("body").splitlines(keepends=True)
    current_architecture: str | None = None
    conditional_architecture: str | None = None
    seen_targets: set[str] = set()
    index = 0
    while index < len(lines):
        architecture = predicate_architecture(lines[index])
        if architecture:
            current_architecture = architecture
            conditional_architecture = architecture
            index += 1
            continue
        if re.fullmatch(r"    else\n?", lines[index]):
            if conditional_architecture is None:
                raise SystemExit(f"verified-hash mode found an unmatched else in {stanza}")
            current_architecture = "amd64" if conditional_architecture == "arm64" else "arm64"
            index += 1
            continue
        if re.fullmatch(r"    end\n?", lines[index]):
            current_architecture = None
            conditional_architecture = None
            index += 1
            continue

        url_match = re.fullmatch(r'(\s+)url "[^"]+"\n?', lines[index])
        if not url_match:
            index += 1
            continue
        if current_architecture is None or index + 1 >= len(lines):
            raise SystemExit(f"verified-hash mode could not bind a {stanza} URL to an architecture predicate")
        sha_match = re.fullmatch(r'(\s+)sha256 "[0-9a-f]+"\n?', lines[index + 1])
        if not sha_match or sha_match.group(1) != url_match.group(1):
            raise SystemExit(f"verified-hash mode requires adjacent URL/checksum pairs in {stanza}")

        target = f"{prefix}_{current_architecture}"
        if target in seen_targets:
            raise SystemExit(f"verified-hash mode found duplicate {target} URL/checksum pairs")
        newline = "\n" if lines[index].endswith("\n") else ""
        indentation = url_match.group(1)
        url = interpolated_target_url(
            repository, tag, formula, version, template, target_aliases, target
        )
        lines[index] = f'{indentation}url "{url}"{newline}'
        lines[index + 1] = f'{indentation}sha256 "{hashes[target]}"{newline}'
        seen_targets.add(target)
        index += 2

    expected_targets = {f"{prefix}_arm64", f"{prefix}_amd64"}
    if seen_targets != expected_targets:
        raise SystemExit(f"verified-hash mode requires exact arm64 and amd64 pairs in {stanza}")
    body = "".join(lines)
    return text[: match.start("body")] + body + text[match.end("body") :]


def target_stanza(
    stanza: str,
    first_target: str,
    second_target: str,
    repository: str,
    tag: str,
    formula: str,
    version: str,
    template: str,
    target_aliases: dict[str, str],
) -> str:
    first_url = target_url(repository, tag, formula, version, template, target_aliases, first_target)
    second_url = target_url(repository, tag, formula, version, template, target_aliases, second_target)
    first_predicate = "Hardware::CPU.arm?" if first_target.endswith("arm64") else "Hardware::CPU.intel?"
    second_predicate = "Hardware::CPU.intel?" if second_target.endswith("amd64") else "Hardware::CPU.arm?"
    if stanza == "on_linux":
        first_predicate = f"{first_predicate} && Hardware::CPU.is_64_bit?"
        second_predicate = f"{second_predicate} && Hardware::CPU.is_64_bit?"

    return f'''  {stanza} do
    if {first_predicate}
      url "{first_url}"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end

    if {second_predicate}
      url "{second_url}"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end
'''


def convert_stanza_url_mode_to_targets(
    text: str,
    repository: str,
    tag: str,
    formula: str,
    version: str,
    template: str,
    target_aliases: dict[str, str],
) -> str:
    replacements = {
        "on_macos": target_stanza(
            "on_macos",
            "darwin_arm64",
            "darwin_amd64",
            repository,
            tag,
            formula,
            version,
            template,
            target_aliases,
        ),
        "on_linux": target_stanza(
            "on_linux",
            "linux_arm64",
            "linux_amd64",
            repository,
            tag,
            formula,
            version,
            template,
            target_aliases,
        ),
    }

    for stanza, replacement in replacements.items():
        match = stanza_match(text, stanza)
        if not match:
            raise SystemExit(f"expected {stanza} stanza for target conversion")
        text = text[: match.start()] + replacement + text[match.end() :]
    return text


def remove_stanza(text: str, stanza: str) -> str:
    match = stanza_match(text, stanza)
    if not match:
        return text
    return text[: match.start()] + text[match.end() :]


def remove_top_level_url_sha(text: str) -> str:
    return re.sub(
        r'^\s*url\s+"[^"]+"\n\s*sha256\s+"[0-9a-f]+"\n',
        "",
        text,
        count=1,
        flags=re.MULTILINE,
    )


def insert_target_stanzas(
    text: str,
    repository: str,
    tag: str,
    formula: str,
    version: str,
    template: str,
    target_aliases: dict[str, str],
) -> str:
    text = remove_stanza(text, "on_macos")
    text = remove_stanza(text, "on_linux")
    text = remove_top_level_url_sha(text)

    stanzas = (
        "\n"
        + target_stanza(
            "on_macos",
            "darwin_arm64",
            "darwin_amd64",
            repository,
            tag,
            formula,
            version,
            template,
            target_aliases,
        )
        + "\n"
        + target_stanza(
            "on_linux",
            "linux_arm64",
            "linux_amd64",
            repository,
            tag,
            formula,
            version,
            template,
            target_aliases,
        )
    )

    match = re.search(r'^(\s*license\s+"[^"]+"\n)', text, flags=re.MULTILINE)
    if not match:
        raise SystemExit("target conversion requires a license line")
    return text[: match.end()] + stanzas + text[match.end() :]


def render_verified_target_formula(
    text: str,
    repository: str,
    tag: str,
    formula: str,
    version: str,
    template: str,
    target_aliases: dict[str, str],
    hashes: dict[str, str],
) -> str:
    text = update_repository_metadata(text, repository)
    text = update_version(text, version)
    text = update_verified_stanza(
        text,
        "on_macos",
        repository,
        tag,
        formula,
        version,
        template,
        target_aliases,
        hashes,
    )
    text = update_verified_stanza(
        text,
        "on_linux",
        repository,
        tag,
        formula,
        version,
        template,
        target_aliases,
        hashes,
    )

    version_lines = re.findall(r'^\s*version\s+"[^"]+"$', text, flags=re.MULTILINE)
    if version_lines != [f'  version "{version}"']:
        raise SystemExit("verified-hash mode requires exactly one canonical formula version line")

    actual_pairs = [
        (match.group("url").replace("#{version}", version), match.group("sha"))
        for match in iter_url_sha_pairs(text)
    ]
    expected_pairs = [
        (
            target_url(repository, tag, formula, version, template, target_aliases, target),
            hashes[target],
        )
        for target in RELEASE_TARGETS
    ]
    if sorted(actual_pairs) != sorted(expected_pairs):
        raise SystemExit("verified-hash rendering did not produce the exact canonical target URL/checksum inventory")
    return text


def update_top_level_url_and_sha(text: str, url: str, digest: str, version: str) -> str:
    text = replace_url_preserving_interpolation(
        text,
        r'^(?P<prefix>\s*url\s+")(?P<url>[^"]+)(?P<suffix>")',
        url,
        version,
        "top-level url",
    )
    return replace_once(
        text,
        r'^(\s*sha256\s+")[^"]+(")',
        rf'\g<1>{digest}\2',
        "top-level sha256",
    )


def update_version(text: str, version: str) -> str:
    return replace_zero_or_one(
        text,
        r'^(\s*version\s+")[^"]+(")',
        rf'\g<1>{version}\2',
        "version",
    )


def update_cask(cask: str, repository: str, tag: str, artifact: str) -> None:
    validate_artifact_token(artifact, "cask artifact")
    version = tag[1:] if tag.startswith("v") else tag
    url = f"https://github.com/{repository}/releases/download/{tag}/{artifact}"
    digest = sha256(url)
    path = tap_path("Casks", cask)
    if not path.exists():
        raise SystemExit(f"{path} does not exist; cask creation needs a manual template")

    text = path.read_text()
    text = update_version(text, version)
    text = update_top_level_url_and_sha(text, url, digest, version)
    path.write_text(text)
    print(f"cask: {digest}  {url}")
    print(f"updated {path} to {version}")


def update_repository_metadata(text: str, repository: str) -> str:
    homepage = f"https://github.com/{repository}"
    head = f"{homepage}.git"
    text = replace_zero_or_one(
        text,
        r'^(?P<prefix>\s*homepage\s+")[^"]+(?P<suffix>")',
        rf'\g<prefix>{homepage}\g<suffix>',
        "homepage",
    )
    return replace_zero_or_one(
        text,
        r'^(?P<prefix>\s*head\s+")[^"]+(?P<suffix>"(?:,\s*branch:\s*"[^"]+")?)',
        rf'\g<prefix>{head}\g<suffix>',
        "head",
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--formula", required=True, help="Formula name, e.g. wacli")
    parser.add_argument("--tag", required=True, help="Release tag, e.g. v0.7.0")
    parser.add_argument("--repository", required=True, help="Source repository, e.g. steipete/wacli")
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

    version = args.tag[1:] if args.tag.startswith("v") else args.tag
    if args.cask and not args.cask_artifact:
        raise SystemExit("--cask-artifact is required when --cask is set")
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
        text = render_verified_target_formula(
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

    cask_artifact = None
    if args.cask_artifact:
        cask_artifact = format_template(args.cask_artifact, args.formula, version, args.tag)
        validate_artifact_token(cask_artifact, "cask artifact")

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
    if not path.exists():
        template = args.artifact_template or "{formula}_{version}_{target}.tar.gz"
        description = args.description or f"{args.formula} command-line tool"
        path.write_text(seed_formula(args.formula, args.repository, version, description, template))
        print(f"created {path}")

    text = path.read_text()
    text = update_repository_metadata(text, args.repository)
    has_macos = has_stanza(text, "on_macos")
    has_linux = has_stanza(text, "on_linux")
    url_sha_pairs = iter_url_sha_pairs(text)
    classified_pairs = [(match, classify_target(match.group("url"), target_aliases, version)) for match in url_sha_pairs]
    target_url_count = sum(1 for _, target in classified_pairs if target)
    has_target_urls = target_url_count > 1 and not uses_stanza_url_mode(text, version)
    if args.artifact_template and not has_target_urls and uses_stanza_url_mode(text, version):
        text = convert_stanza_url_mode_to_targets(
            text,
            args.repository,
            args.tag,
            args.formula,
            version,
            args.artifact_template,
            target_aliases,
        )
        url_sha_pairs = iter_url_sha_pairs(text)
        classified_pairs = [(match, classify_target(match.group("url"), target_aliases, version)) for match in url_sha_pairs]
        target_url_count = sum(1 for _, target in classified_pairs if target)
        has_target_urls = target_url_count > 1
    elif args.artifact_template and not has_target_urls:
        text = insert_target_stanzas(
            text,
            args.repository,
            args.tag,
            args.formula,
            version,
            args.artifact_template,
            target_aliases,
        )
        url_sha_pairs = iter_url_sha_pairs(text)
        classified_pairs = [(match, classify_target(match.group("url"), target_aliases, version)) for match in url_sha_pairs]
        target_url_count = sum(1 for _, target in classified_pairs if target)
        has_target_urls = target_url_count > 1
    if has_macos != has_linux and not has_target_urls:
        raise SystemExit("formulae with only one platform stanza need manual updates")

    text = update_version(text, version)

    if has_target_urls:
        template = args.artifact_template or "{formula}_{version}_{target}.tar.gz"
        replacements: list[tuple[int, int, str]] = []
        seen_targets: set[str] = set()
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
            seen_targets.add(target)
            print(f"{target}: {digest}  {url}")
        for target in sorted(set(RELEASE_TARGETS).intersection(seen_targets ^ set(RELEASE_TARGETS))):
            if target_url_count >= 4:
                raise SystemExit(f"failed to update {target} in {path}")
        for start, end, replacement in reversed(replacements):
            text = text[:start] + replacement + text[end:]

        if args.linux_url:
            linux_sha = sha256(linux_url)
            text = replace_zero_or_one(
                text,
                r'(?P<prefix>url "https://github\.com/[^"]+/archive/refs/tags/[^"]+"\n\s+sha256 ")[0-9a-f]+(?P<suffix>")',
                rf'\g<prefix>{linux_sha}\g<suffix>',
                "source archive sha256",
            )
            print(f"Linux source: {linux_sha}  {linux_url}")
    else:
        macos_sha = sha256(macos_url)
        if has_macos:
            text = update_url_and_sha_in_stanza(text, "on_macos", macos_url, macos_sha, version)
            linux_sha = sha256(linux_url)
            text = update_url_and_sha_in_stanza(text, "on_linux", linux_url, linux_sha, version)
        else:
            text = update_top_level_url_and_sha(text, macos_url, macos_sha, version)
            linux_sha = None
        print(f"macOS: {macos_sha}  {macos_url}")
        if linux_sha:
            print(f"Linux: {linux_sha}  {linux_url}")

    path.write_text(text)

    print(f"updated {path} to {version}")
    if args.cask:
        assert cask_artifact is not None
        update_cask(args.cask, args.repository, args.tag, cask_artifact)
    return 0


if __name__ == "__main__":
    sys.exit(main())
