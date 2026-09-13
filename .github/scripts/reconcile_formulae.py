#!/usr/bin/env python3
"""Reconcile tap formulae with their latest stable GitHub releases."""

from __future__ import annotations

import argparse
import dataclasses
import difflib
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request
from collections.abc import Callable

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import update_formula


USER_AGENT = "openclaw-homebrew-tap-reconciler"
SEMVER_PATTERN = re.compile(
    r"^v?(?P<major>0|[1-9][0-9]*)\."
    r"(?P<minor>0|[1-9][0-9]*)\."
    r"(?P<patch>0|[1-9][0-9]*)"
    r"(?:-(?P<prerelease>[0-9A-Za-z.-]+))?"
    r"(?:\+(?P<build>[0-9A-Za-z.-]+))?$"
)
HOMEPAGE_PATTERN = re.compile(
    r'^\s*homepage\s+"https://github\.com/([^/"\s]+/[^/"\s]+)"\s*$',
    re.MULTILINE,
)
VERSION_PATTERN = re.compile(r'^\s*version\s+"([^"]+)"\s*$', re.MULTILINE)


@dataclasses.dataclass(frozen=True)
class SemanticVersion:
    major: int
    minor: int
    patch: int
    prerelease: tuple[str, ...] = ()

    def compare(self, other: "SemanticVersion") -> int:
        core = (self.major, self.minor, self.patch)
        other_core = (other.major, other.minor, other.patch)
        if core != other_core:
            return (core > other_core) - (core < other_core)
        if not self.prerelease or not other.prerelease:
            return (not self.prerelease) - (not other.prerelease)
        for left, right in zip(self.prerelease, other.prerelease):
            if left == right:
                continue
            left_numeric = left.isdigit()
            right_numeric = right.isdigit()
            if left_numeric and right_numeric:
                return (int(left) > int(right)) - (int(left) < int(right))
            if left_numeric != right_numeric:
                return -1 if left_numeric else 1
            return (left > right) - (left < right)
        return (len(self.prerelease) > len(other.prerelease)) - (
            len(self.prerelease) < len(other.prerelease)
        )


@dataclasses.dataclass(frozen=True)
class FormulaInfo:
    name: str
    path: pathlib.Path
    repository: str
    current_tag: str
    current_version: SemanticVersion
    update_options: tuple[str, ...]


@dataclasses.dataclass(frozen=True)
class Release:
    tag: str
    draft: bool
    prerelease: bool


@dataclasses.dataclass
class Summary:
    scanned: int = 0
    current: int = 0
    drift: int = 0
    updated: int = 0
    refused: int = 0
    skipped: int = 0
    failed: int = 0


class RateLimitError(RuntimeError):
    """Raised when GitHub asks the bounded scan to stop making requests."""


def parse_semver(value: str) -> SemanticVersion:
    match = SEMVER_PATTERN.fullmatch(value)
    if not match:
        raise ValueError(f"{value!r} is not a semantic version")
    prerelease = tuple((match.group("prerelease") or "").split("."))
    if prerelease == ("",):
        prerelease = ()
    return SemanticVersion(
        int(match.group("major")),
        int(match.group("minor")),
        int(match.group("patch")),
        prerelease,
    )


def source_release_urls(text: str, repository: str, version: str) -> list[tuple[str, str]]:
    prefix = f"https://github.com/{repository}/releases/download/"
    urls: list[tuple[str, str]] = []
    for pair in update_formula.iter_url_sha_pairs(text):
        url = pair.group("url").replace("#{version}", version)
        if not url.lower().startswith(prefix.lower()):
            continue
        remainder = url[len(prefix) :]
        if "/" not in remainder:
            raise ValueError(f"release URL has no asset name: {url}")
        tag, asset = remainder.split("/", 1)
        urls.append((tag, asset))
    return urls


def marker_for_target(asset: str, target: str) -> str:
    matches = [marker for marker in update_formula.target_markers(target) if marker in asset]
    if not matches:
        raise ValueError(f"cannot identify the {target} marker in {asset!r}")
    return matches[0]


def infer_update_options(
    text: str,
    repository: str,
    current_tag: str,
    version: str,
) -> tuple[str, ...]:
    release_urls = source_release_urls(text, repository, version)
    if not release_urls:
        raise ValueError("formula has no source-repository release asset URL/checksum pair")

    if len(release_urls) == 1:
        tag, asset = release_urls[0]
        url_template = (
            f"https://github.com/{repository}/releases/download/{{tag}}/"
            + asset.replace(version, "{version}")
        )
        if tag != current_tag:
            raise ValueError(f"release URL tag {tag!r} does not match current tag {current_tag!r}")
        update_formula.validate_template(
            url_template,
            "reconciler artifact URL template",
            frozenset(("formula", "version", "tag")),
        )
        return ("--artifact-url", url_template)

    templates: set[str] = set()
    aliases: dict[str, str] = {}
    targets: set[str] = set()
    for tag, asset in release_urls:
        if tag != current_tag:
            raise ValueError(f"release URL tag {tag!r} does not match current tag {current_tag!r}")
        target = update_formula.classify_target(asset, {}, version)
        if target not in update_formula.RELEASE_TARGETS:
            raise ValueError(f"cannot classify release asset {asset!r}")
        if target in targets:
            raise ValueError(f"formula has duplicate {target} release assets")
        targets.add(target)
        marker = marker_for_target(asset, target)
        aliases[target] = marker
        templates.add(asset.replace(version, "{version}").replace(marker, "{target}", 1))

    if len(templates) != 1:
        raise ValueError(f"release assets do not share one artifact template: {sorted(templates)}")
    template = templates.pop()
    update_formula.validate_template(template, "reconciler artifact template")
    options = ["--artifact-template", template]
    noncanonical_aliases = [
        f"{target}={aliases[target]}"
        for target in update_formula.RELEASE_TARGETS
        if target in aliases and aliases[target] != target
    ]
    if noncanonical_aliases:
        options.extend(("--target-aliases", ",".join(noncanonical_aliases)))
    return tuple(options)


def parse_formula(path: pathlib.Path) -> FormulaInfo:
    text = path.read_text()
    homepages = HOMEPAGE_PATTERN.findall(text)
    if len(homepages) != 1:
        raise ValueError(f"expected one GitHub homepage, found {len(homepages)}")
    repository = homepages[0]

    versions = VERSION_PATTERN.findall(text)
    if len(versions) > 1:
        raise ValueError(f"expected at most one formula version, found {len(versions)}")
    explicit_version = versions[0] if versions else None
    release_urls = source_release_urls(text, repository, explicit_version or "")
    if not release_urls:
        raise ValueError("cannot infer current version without a source-repository release URL")

    release_tags = {tag.replace("#{version}", explicit_version or "") for tag, _ in release_urls}
    if len(release_tags) != 1:
        raise ValueError(f"formula release URLs disagree on tag: {sorted(release_tags)}")
    current_tag = release_tags.pop()
    tag_version = parse_semver(current_tag)
    if tag_version.prerelease:
        raise ValueError(f"current formula tag {current_tag!r} is a prerelease")
    if explicit_version is not None and parse_semver(explicit_version).compare(tag_version) != 0:
        raise ValueError(f"formula version {explicit_version!r} does not match release tag {current_tag!r}")
    version_text = explicit_version or current_tag.removeprefix("v")

    try:
        update_options = infer_update_options(
            text,
            repository,
            current_tag,
            version_text,
        )
    except SystemExit as error:
        raise ValueError(str(error)) from error

    return FormulaInfo(
        name=path.stem,
        path=path,
        repository=repository,
        current_tag=current_tag,
        current_version=parse_semver(version_text),
        update_options=update_options,
    )


def fetch_latest_release(repository: str) -> Release | None:
    request = urllib.request.Request(
        f"https://api.github.com/repos/{repository}/releases/latest",
        headers={
            "Accept": "application/vnd.github+json",
            "User-Agent": USER_AGENT,
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    token = os.environ.get("GH_TOKEN")
    if token:
        request.add_header("Authorization", f"Bearer {token}")
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            payload = json.load(response)
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        if error.code in (403, 429):
            retry_after = error.headers.get("Retry-After") or error.headers.get("X-RateLimit-Reset")
            detail = f"; retry after/reset {retry_after}" if retry_after else ""
            raise RateLimitError(f"GitHub API returned HTTP {error.code}{detail}") from error
        raise RuntimeError(f"GitHub API returned HTTP {error.code}") from error
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError(f"GitHub release lookup failed: {error}") from error

    if not isinstance(payload, dict) or not isinstance(payload.get("tag_name"), str):
        raise RuntimeError("GitHub latest-release response has no tag_name")
    return Release(
        tag=payload["tag_name"],
        draft=payload.get("draft") is True,
        prerelease=payload.get("prerelease") is True,
    )


def run_update(root: pathlib.Path, info: FormulaInfo, latest_tag: str, dry_run: bool) -> None:
    command = [
        sys.executable,
        str(pathlib.Path(__file__).with_name("update_formula.py")),
        "--formula",
        info.name,
        "--tag",
        latest_tag,
        "--repository",
        info.repository,
        *info.update_options,
    ]

    if not dry_run:
        subprocess.run(command, cwd=root, check=True)
        return

    with tempfile.TemporaryDirectory(prefix="tap-reconcile-") as directory:
        scratch = pathlib.Path(directory)
        (scratch / "Formula").mkdir()
        scratch_formula = scratch / "Formula" / info.path.name
        shutil.copy2(info.path, scratch_formula)
        subprocess.run(command, cwd=scratch, check=True)
        updated = scratch_formula.read_text()
    original = info.path.read_text()
    if updated == original:
        raise RuntimeError("newer release produced no formula change")
    print(
        "".join(
            difflib.unified_diff(
                original.splitlines(keepends=True),
                updated.splitlines(keepends=True),
                fromfile=str(info.path),
                tofile=f"{info.path} (reconciled)",
            )
        ),
        end="",
    )


def formula_paths(root: pathlib.Path, selected: str | None) -> list[pathlib.Path]:
    if selected:
        if not update_formula.TAP_TOKEN_PATTERN.fullmatch(selected):
            raise ValueError(f"invalid formula {selected!r}")
        path = root / "Formula" / f"{selected}.rb"
        if not path.is_file():
            raise ValueError(f"formula {selected!r} does not exist")
        return [path]
    return sorted((root / "Formula").glob("*.rb"))


def reconcile(
    root: pathlib.Path,
    selected: str | None,
    dry_run: bool,
    release_lookup: Callable[[str], Release | None] = fetch_latest_release,
    updater: Callable[[pathlib.Path, FormulaInfo, str, bool], None] = run_update,
) -> Summary:
    summary = Summary()
    for path in formula_paths(root, selected):
        summary.scanned += 1
        try:
            info = parse_formula(path)
        except (OSError, ValueError) as error:
            summary.skipped += 1
            print(f"SKIP {path.stem}: {error}")
            continue

        try:
            release = release_lookup(info.repository)
        except RateLimitError as error:
            summary.skipped += 1
            print(f"BACKOFF {info.name}: {error}; stopping this bounded scan")
            break
        except RuntimeError as error:
            summary.skipped += 1
            print(f"SKIP {info.name}: {error}")
            continue
        if release is None:
            summary.skipped += 1
            print(f"SKIP {info.name}: {info.repository} has no published release")
            continue
        if release.draft or release.prerelease:
            summary.skipped += 1
            print(f"SKIP {info.name}: latest release {release.tag} is draft or prerelease")
            continue
        try:
            latest_version = parse_semver(release.tag)
        except ValueError as error:
            summary.skipped += 1
            print(f"SKIP {info.name}: {error}")
            continue
        if latest_version.prerelease:
            summary.skipped += 1
            print(f"SKIP {info.name}: tag {release.tag} has prerelease semantics")
            continue

        comparison = latest_version.compare(info.current_version)
        if comparison < 0:
            summary.refused += 1
            print(f"REFUSE {info.name}: latest {release.tag} is older than current {info.current_tag}")
            continue
        if comparison == 0:
            summary.current += 1
            print(f"CURRENT {info.name}: {info.current_tag}")
            continue

        summary.drift += 1
        print(f"DRIFT {info.name}: {info.current_tag} -> {release.tag}")
        try:
            updater(root, info, release.tag, dry_run)
        except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
            summary.failed += 1
            print(f"FAILED {info.name}: {error}")
            continue
        summary.updated += 1
        action = "WOULD UPDATE" if dry_run else "UPDATED"
        print(f"{action} {info.name}: {info.current_tag} -> {release.tag}")

    return summary


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--formula", help="Only reconcile this formula")
    parser.add_argument("--dry-run", action="store_true", help="Verify and show updates without changing the checkout")
    parser.add_argument("--root", type=pathlib.Path, default=pathlib.Path.cwd(), help=argparse.SUPPRESS)
    args = parser.parse_args(argv)
    root = args.root.resolve()
    try:
        summary = reconcile(root, args.formula, args.dry_run)
    except ValueError as error:
        parser.error(str(error))
    print(
        "SUMMARY "
        f"scanned={summary.scanned} current={summary.current} drift={summary.drift} "
        f"updated={summary.updated} refused={summary.refused} skipped={summary.skipped} failed={summary.failed}"
    )
    return 1 if summary.failed else 0


if __name__ == "__main__":
    sys.exit(main())
