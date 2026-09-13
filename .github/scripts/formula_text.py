"""Pure Homebrew formula text parsing and rendering; no downloads or file writes."""

from __future__ import annotations

import re


RELEASE_TARGETS = ("darwin_amd64", "darwin_arm64", "linux_amd64", "linux_arm64")


def ruby_string(value: str) -> str:
    escaped = (
        value.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("#{", "\\#{")
        .replace("\r", "\\r")
        .replace("\n", "\\n")
    )
    return f'"{escaped}"'


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


def target_markers(target: str, alias: str | None = None) -> tuple[str, ...]:
    markers = {target, target.replace("_", "-")}
    if target == "darwin_amd64":
        markers.update(("macos-x86_64", "macos-amd64", "darwin-x86_64", "x86_64-apple-darwin"))
    elif target == "darwin_arm64":
        markers.update(("macos-arm64", "darwin-aarch64", "aarch64-apple-darwin"))
    elif target == "linux_amd64":
        markers.update(("linux-x86_64", "linux-amd64", "x86_64-unknown-linux-gnu"))
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
            r'(?P<prefix>url ")(?P<url>[^"]+)'
            r'(?P<middle>"\n(?:[ \t]+version "[^"\n]+"\n)?\s+sha256 ")'
            r'(?P<sha>[0-9a-f]+)(?P<suffix>")',
            text,
            flags=re.MULTILINE,
        )
    )


def iter_primary_url_sha_pairs(text: str) -> list[re.Match[str]]:
    resources = list(re.finditer(
        r'^(?P<indent>[ \t]+)resource [^\n]+\n.*?^(?P=indent)end(?:[ \t]*\n|$)',
        text,
        re.MULTILINE | re.DOTALL,
    ))
    return [
        pair for pair in iter_url_sha_pairs(text)
        if not any(resource.start() <= pair.start() < resource.end() for resource in resources)
    ]


def stanza_body(text: str, stanza: str) -> str | None:
    match = stanza_match(text, stanza)
    return match.group("body") if match else None


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
        rf'(?P<header>^\s*{stanza}\s+do\s*$\n)(?P<body>.*?)(?=^\s*(?:on_macos\s+do|on_linux\s+do|resource\s+|head |def |test do))',
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


def update_target_stanza(
    text: str,
    stanza: str,
    assets: dict[str, tuple[str, str]],
    mode: str,
) -> str:
    matches = list(re.finditer(rf"^  {stanza} do$", text, flags=re.MULTILINE))
    match = stanza_match(text, stanza)
    if len(matches) != 1 or match is None:
        raise SystemExit(f"{mode} requires exactly one {stanza} stanza")

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
                raise SystemExit(f"{mode} found an unmatched else in {stanza}")
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
            raise SystemExit(f"{mode} could not bind a {stanza} URL to an architecture predicate")
        sha_match = re.fullmatch(r'(\s+)sha256 "[0-9a-f]+"\n?', lines[index + 1])
        if not sha_match or sha_match.group(1) != url_match.group(1):
            raise SystemExit(f"{mode} requires adjacent URL/checksum pairs in {stanza}")

        target = f"{prefix}_{current_architecture}"
        if target in seen_targets:
            raise SystemExit(f"{mode} found duplicate {target} URL/checksum pairs")
        newline = "\n" if lines[index].endswith("\n") else ""
        indentation = url_match.group(1)
        url, digest = assets[target]
        lines[index] = f'{indentation}url "{url}"{newline}'
        lines[index + 1] = f'{indentation}sha256 "{digest}"{newline}'
        seen_targets.add(target)
        index += 2

    expected_targets = {f"{prefix}_arm64", f"{prefix}_amd64"}
    if seen_targets != expected_targets:
        raise SystemExit(f"{mode} requires exact arm64 and amd64 pairs in {stanza}")
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
    assets = {
        target: (
            interpolated_target_url(repository, tag, formula, version, template, target_aliases, target),
            hashes[target],
        )
        for target in RELEASE_TARGETS
    }
    for stanza in ("on_macos", "on_linux"):
        text = update_target_stanza(text, stanza, assets, "verified-hash mode")

    version_lines = re.findall(r"^\s*version(?:\s|$).*$", text, flags=re.MULTILINE)
    if version_lines and version_lines != [f'  version "{version}"']:
        raise SystemExit(
            "verified-hash mode requires zero or one canonical formula version line "
            "matching the requested version"
        )

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


def render_explicit_target_formula(
    text: str,
    repository: str,
    version: str,
    target_assets: dict[str, tuple[str, str]],
) -> str:
    text = update_repository_metadata(text, repository)
    text = update_version(text, version)
    for stanza in ("on_macos", "on_linux"):
        text = update_target_stanza(text, stanza, target_assets, "explicit-assets mode")
    actual_pairs = sorted(
        (match.group("url").replace("#{version}", version), match.group("sha"))
        for stanza in ("on_macos", "on_linux")
        for match in iter_url_sha_pairs(stanza_body(text, stanza) or "")
    )
    expected_pairs = sorted(target_assets[target] for target in RELEASE_TARGETS)
    if actual_pairs != expected_pairs:
        raise SystemExit("explicit-assets rendering did not produce the exact target URL/checksum inventory")
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
