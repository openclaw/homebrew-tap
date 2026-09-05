from __future__ import annotations

import hashlib
import importlib.util
import io
import json
import os
import pathlib
import re
import tempfile
import unittest
import urllib.error
from unittest import mock


ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / ".github" / "scripts" / "update_formula.py"
SPEC = importlib.util.spec_from_file_location("update_formula", SCRIPT)
assert SPEC and SPEC.loader
update_formula = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(update_formula)


def platform_install_formula() -> str:
    lines = [
        "class Example < Formula",
        '  desc "Example CLI"',
        '  homepage "https://github.com/openclaw/example"',
        '  license "MIT"',
    ]
    for platform, target_os in (("macos", "darwin"), ("linux", "linux")):
        lines.append(f"  on_{platform} do")
        for cpu, arch in (("intel", "amd64"), ("arm", "arm64")):
            lines.extend([
                f"    if Hardware::CPU.{cpu}?",
                f'      url "https://github.com/openclaw/example/releases/download/v0.43.0/'
                f'example_0.43.0_{target_os}_{arch}.tar.gz"',
                f'      sha256 "{"a" * 64}"',
                "      define_method(:install) do",
                '        bin.install "example"',
                '        bin.install "example-helper" if OS.mac? && Hardware::CPU.arm?',
                "      end",
                "    end",
            ])
        lines.append("  end")
    return "\n".join([*lines, "  test do", '    system bin/"example", "--version"', "  end", "end", ""])


def crabbox_assets() -> dict[str, dict[str, str]]:
    return {
        target: {
            "name": f"crabbox_1.2.3_{target}.tar.gz",
            "sha256": hashlib.sha256(target.encode()).hexdigest(),
        }
        for target in update_formula.RELEASE_TARGETS
    }


def crabbox_arguments(mode: str) -> list[str]:
    arguments = ["--formula", "crabbox", "--tag", "v1.2.3", "--repository", "openclaw/crabbox"]
    if mode == "explicit-assets":
        arguments += ["--assets-json", json.dumps(crabbox_assets())]
    elif mode in ("legacy-template", "verified-hashes"):
        arguments += ["--artifact-template", "{formula}_{version}_{target}.tar.gz"]
    elif mode == "legacy-url":
        arguments += ["--artifact-url", "https://example.test/{formula}_{version}.tar.gz"]
    if mode == "verified-hashes":
        for target in update_formula.RELEASE_TARGETS:
            arguments += [f"--{target.replace('_', '-')}-sha256", "e" * 64]
        arguments += [
            "--source-tag-object", "b" * 40,
            "--source-tag-commit", "a" * 40,
            "--request-id", "crabbox-contract-regression",
        ]
    return arguments


class UpdateFormulaTest(unittest.TestCase):
    def assert_crabbox_verified_write_rejection(self, root: pathlib.Path, arguments: list[str]) -> None:
        before = {path.relative_to(root): path.read_bytes() for path in root.rglob("*") if path.is_file()}
        previous_directory = pathlib.Path.cwd()
        os.chdir(root)
        try:
            with (
                mock.patch.multiple(
                    update_formula,
                    sha256=mock.DEFAULT,
                    verify_remote_source_tag=mock.DEFAULT,
                    seed_formula=mock.DEFAULT,
                    update_cask=mock.DEFAULT,
                ) as operations,
                mock.patch.object(update_formula.urllib.request, "urlopen") as network,
                mock.patch.object(update_formula.subprocess, "run") as process,
                mock.patch.object(pathlib.Path, "write_text") as write,
            ):
                for operation in (*operations.values(), network, process, write):
                    operation.side_effect = AssertionError("side effect before obsolete-contract rejection")
                with self.assertRaisesRegex(SystemExit, "Crabbox.*ordinary.*assets.*docs/RELEASING.md"):
                    update_formula.main(arguments)
                for operation in (*operations.values(), network, process, write):
                    operation.assert_not_called()
        finally:
            os.chdir(previous_directory)
        self.assertEqual(
            {path.relative_to(root): path.read_bytes() for path in root.rglob("*") if path.is_file()}, before
        )

    def test_crabbox_rejects_verified_hash_writes_before_side_effects(self) -> None:
        for existing in (False, True):
            for cask in (False, True):
                with self.subTest(existing=existing, cask=cask), tempfile.TemporaryDirectory() as directory:
                    root = pathlib.Path(directory)
                    (root / "Formula").mkdir()
                    (root / "Casks").mkdir()
                    if existing:
                        (root / "Formula" / "crabbox.rb").write_bytes((ROOT / "Formula" / "crabbox.rb").read_bytes())
                        (root / "Casks" / "example.rb").write_text('cask "example" do\nend\n')
                    arguments = crabbox_arguments("verified-hashes")
                    if cask:
                        arguments += ["--cask", "example", "--cask-artifact", "example-{version}.zip"]
                    self.assert_crabbox_verified_write_rejection(root, arguments)

    def test_crabbox_path_aliases_cannot_bypass_verified_hash_write_rejection(self) -> None:
        for alias in ("symlink", "dangling-symlink", "hardlink", "cask-directory"):
            with self.subTest(alias=alias), tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                (root / "Formula").mkdir()
                managed = root / "Formula" / "crabbox.rb"
                if alias != "dangling-symlink":
                    managed.write_bytes((ROOT / "Formula" / "crabbox.rb").read_bytes())
                path = root / "Formula" / "example.rb"
                arguments = crabbox_arguments("verified-hashes")
                arguments[1] = "example"
                if alias == "hardlink":
                    path.hardlink_to(managed)
                elif alias == "cask-directory":
                    path.write_text(platform_install_formula())
                    (root / "Casks").symlink_to("Formula", target_is_directory=True)
                    arguments += ["--cask", "crabbox", "--cask-artifact", "example.zip"]
                else:
                    path.symlink_to("crabbox.rb")
                self.assert_crabbox_verified_write_rejection(root, arguments)

    def test_crabbox_ordinary_updates_download_all_targets_and_preserve_content(self) -> None:
        original = (ROOT / "Formula" / "crabbox.rb").read_text()
        assets = crabbox_assets()
        expected = original
        for match in update_formula.iter_url_sha_pairs(original):
            target = update_formula.classify_target(match.group("url"), {}, "1.2.3")
            item = assets[target]
            expected = expected.replace(match.group("url"), update_formula.explicit_asset_url(
                "openclaw/crabbox", "v1.2.3", item["name"],
            )).replace(match.group("sha"), item["sha256"])
        urls = {
            update_formula.explicit_asset_url("openclaw/crabbox", "v1.2.3", item["name"]): target.encode()
            for target, item in assets.items()
        }
        for mode in ("explicit-assets", "legacy", "legacy-template"):
            with self.subTest(mode=mode), tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                (root / "Formula").mkdir()
                path = root / "Formula" / "crabbox.rb"
                path.write_text(original)
                other = root / "Formula" / "example.rb"
                other.write_text(platform_install_formula())
                previous_directory = pathlib.Path.cwd()
                os.chdir(root)
                try:
                    for current in (False, True):
                        before = path.read_bytes()

                        def download(request, **_kwargs):
                            self.assertEqual(path.read_bytes(), before)
                            return io.BytesIO(urls[request.full_url])

                        with (
                            mock.patch.object(update_formula.urllib.request, "urlopen", side_effect=download) as network,
                            mock.patch.object(update_formula, "verify_remote_source_tag") as verify_tag,
                        ):
                            self.assertEqual(update_formula.main(crabbox_arguments(mode)), 0)
                        self.assertCountEqual([call.args[0].full_url for call in network.call_args_list], urls)
                        verify_tag.assert_not_called()
                        self.assertEqual(path.read_text(), expected)
                        if current:
                            self.assertEqual(path.read_bytes(), before)
                    self.assertEqual(other.read_text(), platform_install_formula())
                finally:
                    os.chdir(previous_directory)

    def test_explicit_asset_failures_leave_no_formula_or_cask_mutations(self) -> None:
        for formula in ("crabbox", "example"):
            for existing in (False, True):
                for failure in ("wrong-hash", "missing-download", "missing-target"):
                    with self.subTest(formula=formula, existing=existing, failure=failure), tempfile.TemporaryDirectory() as directory:
                        root = pathlib.Path(directory)
                        (root / "Formula").mkdir()
                        (root / "Casks").mkdir()
                        path = root / "Formula" / f"{formula}.rb"
                        if existing:
                            path.write_text((ROOT / "Formula" / "crabbox.rb").read_text())
                        (root / "Casks" / "example.rb").write_text('cask "example" do\nend\n')
                        before = {p.relative_to(root): p.read_bytes() for p in root.rglob("*.rb")}
                        assets = crabbox_assets()
                        if failure == "missing-target":
                            del assets["linux_arm64"]
                        arguments = [
                            "--formula", formula, "--tag", "v1.2.3", "--repository", "openclaw/crabbox",
                            "--assets-json", json.dumps(assets), "--cask", "example", "--cask-artifact", "example.zip",
                        ]

                        def download(request, **_kwargs):
                            self.assertEqual({p.relative_to(root): p.read_bytes() for p in root.rglob("*.rb")}, before)
                            target = next(t for t, item in assets.items() if request.full_url.endswith(item["name"]))
                            if target == "linux_arm64":
                                if failure == "missing-download":
                                    raise urllib.error.HTTPError(request.full_url, 404, "missing asset", {}, None)
                                return io.BytesIO(b"wrong bytes")
                            return io.BytesIO(target.encode())

                        previous_directory = pathlib.Path.cwd()
                        os.chdir(root)
                        try:
                            with (
                                mock.patch.object(update_formula.urllib.request, "urlopen", side_effect=download) as network,
                                mock.patch.object(update_formula, "update_cask") as cask,
                                self.assertRaisesRegex(
                                    (SystemExit, urllib.error.HTTPError),
                                    "SHA-256 mismatch|404|must contain exactly",
                                ),
                            ):
                                update_formula.main(arguments)
                            self.assertEqual(network.call_count, 0 if failure == "missing-target" else 4)
                            cask.assert_not_called()
                        finally:
                            os.chdir(previous_directory)
                        self.assertEqual({p.relative_to(root): p.read_bytes() for p in root.rglob("*.rb")}, before)

    def test_explicit_assets_create_missing_formula_only_after_verification(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / "Formula").mkdir()
            path = root / "Formula" / "crabbox.rb"

            def download(request, **_kwargs):
                self.assertFalse(path.exists())
                target = next(t for t, item in crabbox_assets().items() if request.full_url.endswith(item["name"]))
                return io.BytesIO(target.encode())

            previous_directory = pathlib.Path.cwd()
            os.chdir(root)
            try:
                with mock.patch.object(update_formula.urllib.request, "urlopen", side_effect=download) as network:
                    self.assertEqual(update_formula.main(crabbox_arguments("explicit-assets")), 0)
                self.assertEqual(network.call_count, 4)
            finally:
                os.chdir(previous_directory)
            pairs = update_formula.iter_url_sha_pairs(path.read_text())
            self.assertCountEqual(
                [(match.group("url"), match.group("sha")) for match in pairs],
                [(update_formula.explicit_asset_url("openclaw/crabbox", "v1.2.3", item["name"]), item["sha256"])
                 for item in crabbox_assets().values()],
            )

    def test_crabbox_complete_verify_only_is_read_only_even_without_formula(self) -> None:
        for existing in (False, True):
            with self.subTest(existing=existing), tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                if existing:
                    (root / "Formula").mkdir()
                    (root / "Formula" / "crabbox.rb").write_bytes((ROOT / "Formula" / "crabbox.rb").read_bytes())
                before = sorted(root.rglob("*"))
                previous_directory = pathlib.Path.cwd()
                os.chdir(root)
                try:
                    with (
                        mock.patch.object(update_formula, "verify_remote_source_tag") as verify_tag,
                        mock.patch.object(update_formula, "sha256") as download,
                        mock.patch.object(update_formula, "seed_formula") as seed,
                        mock.patch.object(update_formula, "update_cask") as cask,
                        mock.patch.object(pathlib.Path, "write_text") as write,
                    ):
                        self.assertEqual(update_formula.main(crabbox_arguments("verified-hashes") + ["--verify-source-tag-only"]), 0)
                        verify_tag.assert_called_once_with("openclaw/crabbox", "v1.2.3", "b" * 40, "a" * 40)
                        for operation in (download, seed, cask, write):
                            operation.assert_not_called()
                finally:
                    os.chdir(previous_directory)
                self.assertEqual(sorted(root.rglob("*")), before)
                if existing:
                    self.assertEqual((root / "Formula" / "crabbox.rb").read_bytes(), (ROOT / "Formula" / "crabbox.rb").read_bytes())

    def test_crabbox_legacy_and_partial_verify_only_fail_before_tag_lookup(self) -> None:
        for extra in ([], ["--darwin-amd64-sha256", "e" * 64]):
            with self.subTest(extra=extra), tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                previous_directory = pathlib.Path.cwd()
                os.chdir(root)
                try:
                    with (
                        mock.patch.object(update_formula, "verify_remote_source_tag") as verify_tag,
                        mock.patch.object(update_formula, "sha256") as download,
                        self.assertRaisesRegex(SystemExit, "requires.*(?:complete|all inputs)"),
                    ):
                        update_formula.main(crabbox_arguments("legacy") + extra + ["--verify-source-tag-only"])
                    verify_tag.assert_not_called()
                    download.assert_not_called()
                finally:
                    os.chdir(previous_directory)
                self.assertEqual(list(root.iterdir()), [])

    def test_gitcrawl_description_matches_archive_search_and_clustering(self) -> None:
        formula = (ROOT / "Formula" / "gitcrawl.rb").read_text()
        description = re.search(r'^  desc "([^"]+)"$', formula, re.MULTILINE)
        self.assertIsNotNone(description)
        assert description is not None
        text = description.group(1)
        for keyword in ("local", "archive", "search", "cluster"):
            with self.subTest(keyword=keyword):
                self.assertIn(keyword, text.lower())
        self.assertNotIn("gh-compatible", text.lower())
        self.assertIn(f"- `gitcrawl` — {text}\n", (ROOT / "README.md").read_text())

    def test_gitcrawl_caveats_document_platform_defaults_and_shim_ownership(self) -> None:
        formula = (ROOT / "Formula" / "gitcrawl.rb").read_text()
        caveats = formula.split("  def caveats\n", 1)[1].split("    EOS", 1)[0]
        platform_paths = {
            "macOS": {
                "~/Library/Application Support/gitcrawl/": ("config", "database", "vectors", "logs"),
                "~/Library/Caches/gitcrawl/": ("cache",),
            },
            "Linux": {
                "${XDG_CONFIG_HOME:-~/.config}/gitcrawl/": ("config",),
                "${XDG_DATA_HOME:-~/.local/share}/gitcrawl/": ("database", "vectors"),
                "${XDG_CACHE_HOME:-~/.cache}/gitcrawl/": ("cache",),
                "${XDG_STATE_HOME:-~/.local/state}/gitcrawl/": ("logs",),
            },
        }
        for platform, paths in platform_paths.items():
            with self.subTest(platform=platform):
                section = re.search(rf"{platform}:\n((?:[ \t]{{8,}}[^\n]+\n)+)", caveats)
                self.assertIsNotNone(section)
                assert section is not None
                for path, purposes in paths.items():
                    line = next((line for line in section.group(1).splitlines() if path in line), "")
                    self.assertTrue(line, f"missing {platform} default: {path}")
                    for purpose in purposes:
                        self.assertIn(purpose, line)

        normalized = " ".join(caveats.lower().split())
        for pattern in (
            r"fresh.*defaults",
            r"absolute xdg overrides.*macos",
            r"legacy paths.*reused",
            r"explicit.*configured paths.*differ",
            r"gitcrawl doctor --json.*active config.*database paths",
            r"gh compatibility shim.*moved to octopool",
            r"keep.*existing gh/octopool setup",
            r"do not symlink gitcrawl as gh",
        ):
            with self.subTest(pattern=pattern):
                self.assertRegex(normalized, pattern)
        for link in ("https://gitcrawl.sh/configuration/", "https://gitcrawl.sh/gh-shim/"):
            with self.subTest(link=link):
                self.assertIn(link, caveats)
        for obsolete in ("GITCRAWL_GH_PATH", "gitcrawl-gh", "symlink the same binary", "ln -s"):
            with self.subTest(obsolete=obsolete):
                self.assertNotIn(obsolete, caveats)
        doctor_guidance = re.search(r"gitcrawl doctor --json[^.]*\.", normalized)
        self.assertIsNotNone(doctor_guidance)
        assert doctor_guidance is not None
        self.assertNotRegex(doctor_guidance.group(0), r"cache|vector|log")

    def test_gitcrawl_release_updates_preserve_maintained_formula_content(self) -> None:
        formula = (ROOT / "Formula" / "gitcrawl.rb").read_text()
        version_match = re.search(r'^  version "(\d+)\.(\d+)\.(\d+)"$', formula, re.MULTILINE)
        self.assertIsNotNone(version_match)
        assert version_match is not None
        major, minor, patch = version_match.groups()
        version = f"{major}.{minor}.{int(patch) + 1}"
        hashes = {target: str(index) * 64 for index, target in enumerate(update_formula.RELEASE_TARGETS, 1)}
        old_pairs = {(match.group("url"), match.group("sha")) for match in update_formula.iter_url_sha_pairs(formula)}
        metadata = r'(?m)^\s*(?:version|url|sha256) "[^"\n]+"$'

        for mode in ("explicit-assets", "legacy-template", "verified-hashes"):
            with self.subTest(mode=mode):
                template = "{formula}_{version}_{target}.tar.gz"
                if mode == "explicit-assets":
                    template = "{formula}_{version}_custom_{target}.tar.gz"
                assets = {
                    target: {"name": template.format(formula="gitcrawl", version=version, target=target), "sha256": digest}
                    for target, digest in hashes.items()
                }
                expected = {
                    f"https://github.com/openclaw/gitcrawl/releases/download/v{version}/{asset['name']}": asset["sha256"]
                    for asset in assets.values()
                }
                arguments = ["--formula", "gitcrawl", "--tag", f"v{version}", "--repository", "openclaw/gitcrawl"]
                if mode == "explicit-assets":
                    arguments += ["--assets-json", json.dumps(assets)]
                else:
                    arguments += ["--artifact-template", template]
                if mode == "verified-hashes":
                    for target, digest in hashes.items():
                        arguments += [f"--{target.replace('_', '-')}-sha256", digest]
                    arguments += [
                        "--source-tag-object", "b" * 40,
                        "--source-tag-commit", "a" * 40,
                        "--request-id", "gitcrawl-caveats-regression",
                    ]

                previous_directory = pathlib.Path.cwd()
                with tempfile.TemporaryDirectory() as directory:
                    root = pathlib.Path(directory)
                    (root / "Formula").mkdir()
                    path = root / "Formula" / "gitcrawl.rb"
                    path.write_text(formula)
                    os.chdir(root)
                    try:
                        with (
                            mock.patch.object(update_formula, "sha256", side_effect=expected.__getitem__) as download,
                            mock.patch.object(update_formula, "verify_remote_source_tag") as verify_tag,
                        ):
                            self.assertEqual(update_formula.main(arguments), 0)
                    finally:
                        os.chdir(previous_directory)
                    updated = path.read_text()

                if mode == "verified-hashes":
                    download.assert_not_called()
                    verify_tag.assert_called_once_with("openclaw/gitcrawl", f"v{version}", "b" * 40, "a" * 40)
                else:
                    verify_tag.assert_not_called()
                    self.assertCountEqual([call.args[0] for call in download.call_args_list], expected)
                pairs = [
                    (match.group("url").replace("#{version}", version), match.group("sha"))
                    for match in update_formula.iter_url_sha_pairs(updated)
                ]
                self.assertCountEqual(pairs, expected.items())
                self.assertTrue(set(pairs).isdisjoint(old_pairs))
                self.assertIn(f'  version "{version}"', updated)
                self.assertNotIn(version_match.group(0), updated)
                # Only release metadata may change: preserve desc, install, caveats, and test verbatim.
                self.assertEqual(re.sub(metadata, "", updated), re.sub(metadata, "", formula))

    def test_validates_dispatch_identifiers(self) -> None:
        self.assertEqual(update_formula.validate_tap_token("gogcli", "formula"), "gogcli")
        self.assertEqual(update_formula.validate_repository("openclaw/gogcli"), "openclaw/gogcli")
        self.assertEqual(update_formula.validate_release_tag("v1.2.3-beta.1"), "v1.2.3-beta.1")

        invalid_values = (
            (update_formula.validate_tap_token, ("../../README", "formula")),
            (update_formula.validate_tap_token, ("Crabbox", "formula")),
            (update_formula.validate_tap_token, ("./crabbox", "formula")),
            (update_formula.validate_repository, ("openclaw/gogcli/extra",)),
            (update_formula.validate_release_tag, ('v1.2.3"\nsystem("id")',)),
        )
        for validator, arguments in invalid_values:
            with self.subTest(arguments=arguments), self.assertRaises(SystemExit):
                validator(*arguments)

    def test_validates_templates_aliases_and_urls(self) -> None:
        self.assertEqual(
            update_formula.validate_template(
                "{formula}_{version}_{target}.tar.gz",
                "artifact template",
            ),
            "{formula}_{version}_{target}.tar.gz",
        )
        self.assertEqual(
            update_formula.parse_target_aliases("darwin_arm64=macos-arm64,linux_amd64=linux-x86_64"),
            {"darwin_arm64": "macos-arm64", "linux_amd64": "linux-x86_64"},
        )
        self.assertEqual(
            update_formula.validate_url("https://github.com/openclaw/gogcli", "URL"),
            "https://github.com/openclaw/gogcli",
        )

        for value in ("{unknown}.tar.gz", "{formula.__class__}.tar.gz"):
            with self.subTest(template=value), self.assertRaises(SystemExit):
                update_formula.validate_template(value, "artifact template")
        for value in (
            "file:///etc/passwd",
            "http://github.com/openclaw/gogcli",
            "https://user@github.com/repo",
            'https://github.com/openclaw/example/releases/download/v1.0.0/evil"#{system}.tar.gz',
        ):
            with self.subTest(url=value), self.assertRaises(SystemExit):
                update_formula.validate_url(value, "URL")
        with self.assertRaises(SystemExit):
            update_formula.parse_target_aliases("unknown=linux-amd64")
        with self.assertRaises(SystemExit):
            update_formula.parse_target_aliases("darwin_arm64=shared,darwin_amd64=shared")

    def test_verified_hash_contract_is_atomic_and_strict(self) -> None:
        hashes = {
            "darwin_amd64": "1" * 64,
            "darwin_arm64": "2" * 64,
            "linux_amd64": "3" * 64,
            "linux_arm64": "4" * 64,
        }
        self.assertEqual(
            update_formula.validate_verified_hash_contract(
                hashes,
                "a" * 40,
                "b" * 40,
                "example-v1.2.3-123",
            ),
            hashes,
        )
        self.assertIsNone(
            update_formula.validate_verified_hash_contract(
                {target: None for target in update_formula.RELEASE_TARGETS},
                None,
                None,
                "legacy-request-id",
            )
        )

        incomplete = dict(hashes)
        incomplete["linux_arm64"] = None
        with self.assertRaisesRegex(SystemExit, "missing linux_arm64_sha256"):
            update_formula.validate_verified_hash_contract(
                incomplete,
                "a" * 40,
                "b" * 40,
                "example-v1.2.3-123",
            )
        with self.assertRaisesRegex(SystemExit, "64 lowercase"):
            update_formula.validate_verified_hash_contract(
                {**hashes, "linux_arm64": "A" * 64},
                "a" * 40,
                "b" * 40,
                "example-v1.2.3-123",
            )
        with self.assertRaisesRegex(SystemExit, "annotated tag"):
            update_formula.validate_verified_hash_contract(
                hashes,
                "a" * 40,
                "a" * 40,
                "example-v1.2.3-123",
            )

    def test_explicit_assets_contract_renders_exact_names_and_rehashes(self) -> None:
        formula = '''class Example < Formula
  desc "Example CLI"
  homepage "https://github.com/openclaw/example"
  version "1.2.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/example/releases/download/v1.2.2/old-darwin-arm64.tar.gz"
      sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    else
      url "https://github.com/openclaw/example/releases/download/v1.2.2/old-darwin-amd64.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/example/releases/download/v1.2.2/old-linux-arm64.tar.gz"
      sha256 "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
    end
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/example/releases/download/v1.2.2/old-linux-amd64.tar.gz"
      sha256 "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
    end
  end

  resource "completion" do
    url "https://example.test/completion.tar.gz"
    sha256 "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
  end

  def install
    bin.install "example"
  end
end
'''
        assets = {
            target: {"name": f"example_1.2.3_custom_{target}_v8.0.tar.gz", "sha256": "e" * 64}
            for target in update_formula.RELEASE_TARGETS
        }
        arguments = [
            "--formula", "example",
            "--tag", "v1.2.3",
            "--repository", "openclaw/example",
            "--assets-json", json.dumps(assets),
        ]

        previous_directory = pathlib.Path.cwd()
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / "Formula").mkdir()
            path = root / "Formula" / "example.rb"
            path.write_text(formula)
            os.chdir(root)
            try:
                with mock.patch.object(update_formula, "sha256", return_value="e" * 64) as download:
                    self.assertEqual(update_formula.main(arguments), 0)
            finally:
                os.chdir(previous_directory)
            updated = path.read_text()

        self.assertEqual(download.call_count, 4)
        self.assertIn('version "1.2.3"', updated)
        self.assertIn('url "https://example.test/completion.tar.gz"', updated)
        self.assertIn('sha256 "' + "f" * 64 + '"', updated)
        for item in assets.values():
            self.assertIn(item["name"], updated)
            self.assertIn(f'sha256 "{item["sha256"]}"', updated)

        self.assertIsNone(update_formula.parse_explicit_assets(None))
        incomplete = dict(assets)
        incomplete.pop("linux_arm64")
        with self.assertRaisesRegex(SystemExit, "must contain exactly"):
            update_formula.parse_explicit_assets(json.dumps(incomplete))
        parsed = update_formula.parse_explicit_assets(json.dumps(assets))
        assert parsed is not None
        with (
            mock.patch.object(update_formula, "sha256", return_value="f" * 64),
            self.assertRaisesRegex(SystemExit, "SHA-256 mismatch"),
        ):
            update_formula.verify_explicit_assets("openclaw/example", "v1.2.3", parsed)

    def test_validates_exact_annotated_source_tag_refs(self) -> None:
        tag = "v1.2.3"
        tag_object = "b" * 40
        tag_commit = "a" * 40
        output = f"{tag_object}\trefs/tags/{tag}\n{tag_commit}\trefs/tags/{tag}^{{}}\n"

        update_formula.validate_source_tag_refs(
            output,
            tag,
            tag_object,
            tag_commit,
        )
        with self.assertRaisesRegex(SystemExit, "does not match"):
            update_formula.validate_source_tag_refs(
                f"{tag_object}\trefs/tags/{tag}\n{'c' * 40}\trefs/tags/{tag}^{{}}\n",
                tag,
                tag_object,
                tag_commit,
            )
        with self.assertRaisesRegex(SystemExit, "invalid or duplicate"):
            update_formula.validate_source_tag_refs(
                output + f"{tag_object}\trefs/tags/{tag}\n",
                tag,
                tag_object,
                tag_commit,
            )

    def test_remote_source_tag_lookup_uses_exact_public_refs_without_credentials(self) -> None:
        tag = "v1.2.3"
        tag_object = "b" * 40
        tag_commit = "a" * 40
        output = f"{tag_object}\trefs/tags/{tag}\n{tag_commit}\trefs/tags/{tag}^{{}}\n"

        def git_result(command: list[str], **_: object) -> update_formula.subprocess.CompletedProcess[str]:
            stdout = ""
            if command[-1] == f"refs/tags/{tag}^{{tag}}":
                stdout = tag_object + "\n"
            elif command[-1] == f"refs/tags/{tag}^{{commit}}":
                stdout = tag_commit + "\n"
            elif "ls-remote" in command:
                stdout = output
            return update_formula.subprocess.CompletedProcess(command, 0, stdout, "")

        with mock.patch.object(update_formula.subprocess, "run", side_effect=git_result) as run:
            update_formula.verify_remote_source_tag(
                "openclaw/example",
                tag,
                tag_object,
                tag_commit,
            )

        commands = [call.args[0] for call in run.call_args_list]
        self.assertEqual(
            commands[-1],
            [
                "git",
                "ls-remote",
                "--tags",
                "https://github.com/openclaw/example.git",
                f"refs/tags/{tag}",
                f"refs/tags/{tag}^{{}}",
            ],
        )
        fetch = next(command for command in commands if "fetch" in command)
        self.assertEqual(
            fetch[-2:],
            [
                "https://github.com/openclaw/example.git",
                f"refs/tags/{tag}:refs/tags/{tag}",
            ],
        )
        self.assertTrue(any(command[-1] == f"refs/tags/{tag}^{{tag}}" for command in commands))
        self.assertTrue(any(command[-1] == f"refs/tags/{tag}^{{commit}}" for command in commands))
        for call in run.call_args_list:
            options = call.kwargs
            command = call.args[0]
            self.assertEqual(options["cwd"], "/")
            self.assertEqual(options["env"]["GIT_CONFIG_GLOBAL"], "/dev/null")
            self.assertEqual(options["env"]["GIT_TERMINAL_PROMPT"], "0")
            self.assertNotIn("GH_TOKEN", options["env"])
            self.assertNotIn("GITHUB_TOKEN", options["env"])
            if "fetch" in command or "ls-remote" in command:
                self.assertEqual(options["timeout"], update_formula.GIT_NETWORK_TIMEOUT_SECONDS)
            else:
                self.assertIsNone(options["timeout"])

    def test_remote_source_tag_rejects_a_non_commit_target(self) -> None:
        tag = "v1.2.3"
        tag_object = "b" * 40
        tag_commit = "a" * 40

        def git_result(command: list[str], **_: object) -> update_formula.subprocess.CompletedProcess[str]:
            if command[-1] == f"refs/tags/{tag}^{{tag}}":
                return update_formula.subprocess.CompletedProcess(command, 0, tag_object + "\n", "")
            if command[-1] == f"refs/tags/{tag}^{{commit}}":
                return update_formula.subprocess.CompletedProcess(command, 128, "", "expected commit type")
            return update_formula.subprocess.CompletedProcess(command, 0, "", "")

        with mock.patch.object(update_formula.subprocess, "run", side_effect=git_result):
            with self.assertRaisesRegex(SystemExit, "does not peel to a commit"):
                update_formula.verify_remote_source_tag(
                    "openclaw/example",
                    tag,
                    tag_object,
                    tag_commit,
                )

    def test_remote_source_tag_network_git_budget_is_documented(self) -> None:
        self.assertEqual(update_formula.GIT_NETWORK_TIMEOUT_SECONDS, 60)

    def test_remote_source_tag_network_git_timeout_fails_closed(self) -> None:
        tag = "v1.2.3"
        tag_object = "b" * 40
        tag_commit = "a" * 40
        output = f"{tag_object}\trefs/tags/{tag}\n{tag_commit}\trefs/tags/{tag}^{{}}\n"

        for network_verb in ("fetch", "ls-remote"):
            with self.subTest(command=network_verb):
                def git_result(
                    command: list[str],
                    verb: str = network_verb,
                    **kwargs: object,
                ) -> update_formula.subprocess.CompletedProcess[str]:
                    if verb in command:
                        raise update_formula.subprocess.TimeoutExpired(command, timeout=kwargs.get("timeout"))
                    stdout = ""
                    if command[-1] == f"refs/tags/{tag}^{{tag}}":
                        stdout = tag_object + "\n"
                    elif command[-1] == f"refs/tags/{tag}^{{commit}}":
                        stdout = tag_commit + "\n"
                    elif "ls-remote" in command:
                        stdout = output
                    return update_formula.subprocess.CompletedProcess(command, 0, stdout, "")

                with mock.patch.object(update_formula.subprocess, "run", side_effect=git_result):
                    with self.assertRaisesRegex(SystemExit, r"timed out after 60s"):
                        update_formula.verify_remote_source_tag(
                            "openclaw/example",
                            tag,
                            tag_object,
                            tag_commit,
                        )

    def test_verified_hash_mode_renders_canonical_targets_without_downloading_assets(self) -> None:
        formula = '''class Example < Formula
  desc "Example CLI"
  homepage "https://github.com/openclaw/example"
  version "1.2.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/example/releases/download/v1.2.2/example_1.2.2_darwin_amd64.tar.gz"
      sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    else
      url "https://github.com/openclaw/example/releases/download/v1.2.2/example_1.2.2_darwin_arm64.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/example/releases/download/v1.2.2/example_1.2.2_linux_arm64.tar.gz"
      sha256 "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/example/releases/download/v1.2.2/example_1.2.2_linux_amd64.tar.gz"
      sha256 "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"
    end
  end

  def install
    bin.install "example"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/example --version")
  end
end
'''
        hashes = {
            "darwin_amd64": "1" * 64,
            "darwin_arm64": "2" * 64,
            "linux_amd64": "3" * 64,
            "linux_arm64": "4" * 64,
        }
        arguments = [
            "--formula",
            "example",
            "--tag",
            "v1.2.3",
            "--repository",
            "openclaw/example",
            "--artifact-template",
            "{formula}_{version}_{target}.tar.gz",
            "--darwin-amd64-sha256",
            hashes["darwin_amd64"],
            "--darwin-arm64-sha256",
            hashes["darwin_arm64"],
            "--linux-amd64-sha256",
            hashes["linux_amd64"],
            "--linux-arm64-sha256",
            hashes["linux_arm64"],
            "--source-tag-commit",
            "a" * 40,
            "--source-tag-object",
            "b" * 40,
            "--request-id",
            "example-v1.2.3-123",
        ]

        previous_directory = pathlib.Path.cwd()
        with self.subTest("verified rendering"), mock.patch.object(
            update_formula, "verify_remote_source_tag"
        ) as verify_tag, mock.patch.object(
            update_formula, "sha256", side_effect=AssertionError("asset download attempted")
        ) as download:
            with tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                (root / "Formula").mkdir()
                path = root / "Formula" / "example.rb"
                path.write_text(formula)
                os.chdir(root)
                try:
                    self.assertEqual(update_formula.main(arguments), 0)
                finally:
                    os.chdir(previous_directory)
                updated = path.read_text()

        verify_tag.assert_called_once_with("openclaw/example", "v1.2.3", "b" * 40, "a" * 40)
        download.assert_not_called()
        self.assertEqual(updated.count('  version "1.2.3"'), 1)
        self.assertIn("if Hardware::CPU.arm?", updated)
        self.assertIn("if Hardware::CPU.intel?", updated)
        self.assertIn("Hardware::CPU.arm? && Hardware::CPU.is_64_bit?", updated)
        self.assertIn("Hardware::CPU.intel? && Hardware::CPU.is_64_bit?", updated)
        for target, digest in hashes.items():
            self.assertIn(
                f'url "https://github.com/openclaw/example/releases/download/v#{{version}}/'
                f'example_#{{version}}_{target}.tar.gz"\n      sha256 "{digest}"',
                updated,
            )
            self.assertEqual(updated.count(digest), 1)

    def test_verified_hash_mode_preserves_formula_specific_install_blocks(self) -> None:
        formula = platform_install_formula()
        hashes = {
            "darwin_amd64": "1" * 64,
            "darwin_arm64": "2" * 64,
            "linux_amd64": "3" * 64,
            "linux_arm64": "4" * 64,
        }

        updated = update_formula.render_verified_target_formula(
            formula,
            "openclaw/example",
            "v0.36.1",
            "example",
            "0.36.1",
            "{formula}_{version}_{target}.tar.gz",
            {},
            hashes,
        )

        self.assertNotRegex(updated, r"(?m)^\s*version(?:\s|$)")
        self.assertEqual(updated.count("define_method(:install) do"), 4)
        self.assertEqual(updated.count('bin.install "example"'), 4)
        self.assertEqual(updated.count('bin.install "example-helper"'), 4)
        for target, digest in hashes.items():
            self.assertIn(f"example_#{{version}}_{target}.tar.gz", updated)
            self.assertEqual(updated.count(digest), 1)

    def test_verified_hash_mode_rejects_duplicate_or_mismatched_version_lines(self) -> None:
        formula = platform_install_formula()
        hashes = {
            "darwin_amd64": "1" * 64,
            "darwin_arm64": "2" * 64,
            "linux_amd64": "3" * 64,
            "linux_arm64": "4" * 64,
        }
        duplicate = formula.replace(
            '  license "MIT"',
            '  version "0.43.0"\n  version "0.43.0"\n  license "MIT"',
        )
        mismatched = formula.replace(
            '  license "MIT"',
            "  version '0.43.0'\n  license \"MIT\"",
        )

        cases = (
            ("duplicate", duplicate, "expected at most one version"),
            ("mismatched", mismatched, "matching the requested version"),
        )
        for description, candidate, message in cases:
            with self.subTest(description=description), self.assertRaisesRegex(SystemExit, message):
                update_formula.render_verified_target_formula(
                    candidate,
                    "openclaw/example",
                    "v0.43.1",
                    "example",
                    "0.43.1",
                    "{formula}_{version}_{target}.tar.gz",
                    {},
                    hashes,
                )

    def test_verified_hash_mode_preserves_formula_metadata_order(self) -> None:
        formula = (ROOT / "Formula" / "wacli.rb").read_text()
        hashes = {
            "darwin_amd64": "1" * 64,
            "darwin_arm64": "2" * 64,
            "linux_amd64": "3" * 64,
            "linux_arm64": "4" * 64,
        }

        updated = update_formula.render_verified_target_formula(
            formula,
            "openclaw/wacli",
            "v0.12.1",
            "wacli",
            "0.12.1",
            "{formula}_{version}_{target}.tar.gz",
            {},
            hashes,
        )

        metadata = (
            'license "MIT"',
            "version_scheme 1",
            'head "https://github.com/openclaw/wacli.git", branch: "main"',
            'depends_on "go" => :build if build.head?',
            "on_macos do",
        )
        self.assertEqual([updated.index(item) for item in metadata], sorted(updated.index(item) for item in metadata))
        self.assertEqual(updated.count("def install"), 1)
        for target, digest in hashes.items():
            self.assertIn(f"wacli_#{{version}}_{target}.tar.gz", updated)
            self.assertEqual(updated.count(digest), 1)

    def test_seed_formula_escapes_ruby_description(self) -> None:
        seeded = update_formula.seed_formula(
            "example",
            "openclaw/example",
            "1.2.3",
            'A "quoted" #{system("id")} description',
            "{formula}_{version}_{target}.tar.gz",
        )

        self.assertIn(r'desc "A \"quoted\" \#{system(\"id\")} description"', seeded)

    def test_seeded_formula_is_not_written_when_checksum_download_fails(self) -> None:
        arguments = [
            "--formula", "example",
            "--tag", "v1.2.3",
            "--repository", "openclaw/example",
            "--artifact-template", "{formula}_{version}_{target}.tar.gz",
        ]
        for when in ("first-target", "later-target"):
            with self.subTest(when=when), tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                (root / "Formula").mkdir()
                path = root / "Formula" / "example.rb"
                seen = {"n": 0}

                def download(url: str) -> str:
                    self.assertFalse(path.exists())
                    seen["n"] += 1
                    if when == "first-target" or seen["n"] > 1:
                        raise SystemExit("download failed")
                    return "e" * 64

                previous_directory = pathlib.Path.cwd()
                os.chdir(root)
                try:
                    with mock.patch.object(update_formula, "sha256", side_effect=download):
                        with self.assertRaisesRegex(SystemExit, "download failed"):
                            update_formula.main(arguments)
                finally:
                    os.chdir(previous_directory)
                self.assertFalse(path.exists())
                self.assertEqual(list(root.rglob("*.rb")), [])

    def test_seeded_formula_is_written_only_after_checksums_succeed(self) -> None:
        arguments = [
            "--formula", "example",
            "--tag", "v1.2.3",
            "--repository", "openclaw/example",
            "--artifact-template", "{formula}_{version}_{target}.tar.gz",
        ]
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / "Formula").mkdir()
            path = root / "Formula" / "example.rb"

            def download(url: str) -> str:
                self.assertFalse(path.exists())
                return hashlib.sha256(url.encode()).hexdigest()

            previous_directory = pathlib.Path.cwd()
            os.chdir(root)
            try:
                with mock.patch.object(update_formula, "sha256", side_effect=download) as hashed:
                    self.assertEqual(update_formula.main(arguments), 0)
                self.assertEqual(hashed.call_count, 4)
            finally:
                os.chdir(previous_directory)
            updated = path.read_text()

        self.assertNotIn("0" * 64, updated)
        self.assertEqual(updated.count("sha256 "), 4)
        for target in update_formula.RELEASE_TARGETS:
            self.assertIn(f"example_#{{version}}_{target}.tar.gz", updated)

    def test_updates_duplicate_source_url_checksums_in_stanza(self) -> None:
        text = '''class Camsnap < Formula
  version "0.2.0"

  on_linux do
    on_intel do
      url "https://github.com/steipete/camsnap/archive/refs/tags/v0.2.0.tar.gz"
      sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    end

    on_arm do
      url "https://github.com/steipete/camsnap/archive/refs/tags/v0.2.0.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end
  end

  def install
  end
end
'''

        updated = update_formula.update_url_and_sha_in_stanza(
            text,
            "on_linux",
            "https://github.com/steipete/camsnap/archive/refs/tags/v0.3.0.tar.gz",
            "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
            "0.3.0",
        )

        self.assertEqual(updated.count("v0.3.0.tar.gz"), 2)
        self.assertEqual(updated.count("cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"), 2)

    def test_target_update_handles_version_length_change(self) -> None:
        formula = update_formula.seed_formula(
            "example",
            "openclaw/example",
            "0.7.9",
            "Example CLI",
            "{formula}_{version}_{target}.tar.gz",
        )
        arguments = [
            "--formula", "example",
            "--tag", "v0.7.10",
            "--repository", "openclaw/example",
            "--artifact-template", "{formula}_{version}_{target}.tar.gz",
        ]

        previous_directory = pathlib.Path.cwd()
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / "Formula").mkdir()
            path = root / "Formula" / "example.rb"
            path.write_text(formula)
            os.chdir(root)
            try:
                with mock.patch.object(update_formula, "sha256", return_value="e" * 64):
                    self.assertEqual(update_formula.main(arguments), 0)
            finally:
                os.chdir(previous_directory)
            updated = path.read_text()

        self.assertIn('version "0.7.10"', updated)
        self.assertEqual(updated.count('sha256 "' + "e" * 64 + '"'), 4)
        self.assertNotIn('""', updated)

    def test_multi_target_update_rejects_unclassified_pair_without_writing(self) -> None:
        mystery_url = (
            "https://github.com/openclaw/example/releases/download/v0.43.0/"
            "example_0.43.0_mystery.tar.gz"
        )
        self.assertIsNone(update_formula.classify_target(mystery_url, {}, "0.43.0"))
        formula = platform_install_formula().replace(
            '  license "MIT"',
            '  version "0.43.0"\n  license "MIT"',
        ).replace("example_0.43.0_linux_arm64.tar.gz", "example_0.43.0_mystery.tar.gz")
        classified = [
            update_formula.classify_target(match.group("url"), {}, "0.43.0")
            for match in update_formula.iter_url_sha_pairs(formula)
        ]
        self.assertEqual(classified.count(None), 1)
        self.assertEqual(len([target for target in classified if target]), 3)
        arguments = [
            "--formula", "example",
            "--tag", "v0.44.0",
            "--repository", "openclaw/example",
            "--artifact-template", "{formula}_{version}_{target}.tar.gz",
        ]

        previous_directory = pathlib.Path.cwd()
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / "Formula").mkdir()
            path = root / "Formula" / "example.rb"
            path.write_text(formula)
            before = path.read_bytes()
            os.chdir(root)
            try:
                with (
                    mock.patch.object(update_formula, "sha256", return_value="e" * 64) as hashed,
                    self.assertRaisesRegex(SystemExit, "unclassified release asset"),
                ):
                    update_formula.main(arguments)
                hashed.assert_not_called()
            finally:
                os.chdir(previous_directory)
            after = path.read_bytes()

        self.assertEqual(after, before)
        self.assertNotIn(b'version "0.44.0"', after)
        self.assertIn(b"example_0.43.0_mystery.tar.gz", after)
        self.assertNotIn(("e" * 64).encode(), after)

    def test_legacy_target_subsets_and_resources_remain_supported(self) -> None:
        def formula_for(targets: tuple[str, ...]) -> str:
            lines = [
                "class Example < Formula",
                '  desc "Example"',
                '  homepage "https://github.com/openclaw/example"',
                '  version "1.2.3"',
                '  license "MIT"',
            ]
            for platform, prefix in (("macos", "darwin"), ("linux", "linux")):
                selected = [target for target in targets if target.startswith(prefix)]
                if not selected:
                    continue
                lines.append(f"  on_{platform} do")
                for target in selected:
                    cpu = "arm" if target.endswith("arm64") else "intel"
                    lines.extend([
                        f"    if Hardware::CPU.{cpu}?",
                        f'      url "https://github.com/openclaw/example/releases/download/v1.2.3/example_1.2.3_{target}.tar.gz"',
                        f'      sha256 "{"a" * 64}"',
                        "    end",
                    ])
                lines.append("  end")
            return "\n".join([*lines, "  def install", '    bin.install "example"', "  end", "end", ""])

        inventories = (
            ("darwin_arm64", "darwin_amd64"),
            ("darwin_arm64", "darwin_amd64", "linux_amd64"),
            ("darwin_universal", "linux_arm64", "linux_amd64"),
            update_formula.RELEASE_TARGETS,
        )
        resource = (
            '  resource "data" do\n'
            '    url "https://example.org/data.tar.gz"\n'
            f'    sha256 "{"f" * 64}"\n'
            '  end\n'
        )
        for targets in inventories:
            with self.subTest(targets=targets), tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                (root / "Formula").mkdir()
                path = root / "Formula/example.rb"
                nested_resource = "\n".join("  " + line if line else line for line in resource.split("\n"))
                fixture = formula_for(targets).replace("  def install", resource + "  def install")
                fixture = fixture.replace("\n  end", "\n" + nested_resource + "  end", 1)
                path.write_text(fixture)
                previous = pathlib.Path.cwd()
                os.chdir(root)
                try:
                    with mock.patch.object(update_formula, "sha256", return_value="e" * 64) as hashed:
                        self.assertEqual(update_formula.main([
                            "--formula", "example", "--repository", "openclaw/example", "--tag", "v1.2.4",
                        ]), 0)
                    self.assertEqual(hashed.call_count, len(targets))
                finally:
                    os.chdir(previous)
                updated = path.read_text()
                self.assertIn(resource, updated)
                self.assertIn(nested_resource, updated)
                self.assertEqual(updated.count('sha256 "' + "e" * 64), len(targets))
                self.assertNotIn("example_1.2.3_", updated)

    def test_legacy_explicit_source_archive_is_handled_but_unknown_pair_is_not(self) -> None:
        archive = "https://github.com/openclaw/example/archive/refs/tags/v0.44.0.tar.gz"
        pair = f'  url "{archive}"\n  sha256 "{"f" * 64}"\n'
        for count in (1, 2):
            with self.subTest(archives=count), tempfile.TemporaryDirectory() as directory:
                root = pathlib.Path(directory)
                (root / "Formula").mkdir()
                path = root / "Formula/example.rb"
                original = platform_install_formula().replace("  on_macos do", pair * count + "  on_macos do")
                path.write_text(original)
                previous = pathlib.Path.cwd()
                os.chdir(root)
                try:
                    with mock.patch.object(update_formula, "sha256", return_value="e" * 64) as hashed:
                        arguments = ["--formula", "example", "--repository", "openclaw/example",
                                     "--tag", "v0.44.0", "--linux-url", archive]
                        if count == 1:
                            self.assertEqual(update_formula.main(arguments), 0)
                            self.assertEqual(hashed.call_count, 5)
                        else:
                            with self.assertRaisesRegex(SystemExit, "at most one source archive"):
                                update_formula.main(arguments)
                            hashed.assert_not_called()
                            self.assertEqual(path.read_text(), original)
                finally:
                    os.chdir(previous)

    def test_multi_target_linux_url_updates_archive_url_and_sha(self) -> None:
        old_archive = "https://github.com/openclaw/example/archive/refs/tags/v0.43.0.tar.gz"
        new_archive = "https://github.com/openclaw/example/archive/refs/tags/v0.44.0.tar.gz"
        formula = platform_install_formula().replace(
            '  license "MIT"\n',
            (
                '  version "0.43.0"\n'
                '  license "MIT"\n'
                f'  url "{old_archive}"\n'
                f'  sha256 "{"f" * 64}"\n'
            ),
        )
        arguments = [
            "--formula", "example",
            "--tag", "v0.44.0",
            "--repository", "openclaw/example",
            "--artifact-template", "{formula}_{version}_{target}.tar.gz",
            "--linux-url", new_archive,
        ]

        def digest_for(url: str) -> str:
            return ("c" if url == new_archive else "e") * 64

        previous_directory = pathlib.Path.cwd()
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / "Formula").mkdir()
            path = root / "Formula" / "example.rb"
            path.write_text(formula)
            os.chdir(root)
            try:
                with mock.patch.object(update_formula, "sha256", side_effect=digest_for):
                    self.assertEqual(update_formula.main(arguments), 0)
            finally:
                os.chdir(previous_directory)
            updated = path.read_text()

        self.assertIn(f'url "{new_archive}"', updated)
        self.assertNotIn(old_archive, updated)
        self.assertIn('sha256 "' + "c" * 64 + '"', updated)
        self.assertNotIn("f" * 64, updated)
        self.assertIn("example_0.44.0_linux_amd64.tar.gz", updated)

    def test_rejects_different_architecture_urls_in_one_stanza(self) -> None:
        text = '''class Example < Formula
  version "1.0.0"

  on_linux do
    on_intel do
      url "https://github.com/steipete/example/releases/download/v1.0.0/example_1.0.0_linux_amd64.tar.gz"
      sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    end

    on_arm do
      url "https://github.com/steipete/example/releases/download/v1.0.0/example_1.0.0_linux_arm64.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end
  end

  def install
  end
end
'''

        with self.assertRaises(SystemExit) as raised:
            update_formula.update_url_and_sha_in_stanza(
                text,
                "on_linux",
                "https://github.com/steipete/example/archive/refs/tags/v1.0.1.tar.gz",
                "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc",
                "1.0.1",
            )

        self.assertIn("multiple architecture-specific checksums", str(raised.exception))

    def test_duplicate_urls_in_platform_stanzas_use_stanza_mode(self) -> None:
        text = '''class Wacli < Formula
  on_macos do
    on_arm do
      url "https://github.com/openclaw/wacli/releases/download/v0.9.1/wacli-macos-universal.tar.gz"
      sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    end

    on_intel do
      url "https://github.com/openclaw/wacli/releases/download/v0.9.1/wacli-macos-universal.tar.gz"
      sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/openclaw/wacli/archive/refs/tags/v0.9.1.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end

    on_intel do
      url "https://github.com/openclaw/wacli/archive/refs/tags/v0.9.1.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end
  end

  def install
  end
end
'''

        self.assertTrue(update_formula.uses_stanza_url_mode(text, "0.9.2"))

    def test_converts_duplicate_platform_stanzas_to_target_urls(self) -> None:
        text = '''class Wacli < Formula
  version "0.9.2"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/wacli/releases/download/v0.9.2/wacli-macos-universal.tar.gz"
      sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    end

    on_intel do
      url "https://github.com/openclaw/wacli/releases/download/v0.9.2/wacli-macos-universal.tar.gz"
      sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/openclaw/wacli/archive/refs/tags/v0.9.2.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end

    on_intel do
      url "https://github.com/openclaw/wacli/archive/refs/tags/v0.9.2.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end
  end

  def install
  end
end
'''

        updated = update_formula.convert_stanza_url_mode_to_targets(
            text,
            "openclaw/wacli",
            "v0.9.3",
            "wacli",
            "0.9.3",
            "{formula}_{version}_{target}.tar.gz",
            {},
        )

        self.assertIn("wacli_0.9.3_darwin_arm64.tar.gz", updated)
        self.assertIn("wacli_0.9.3_darwin_amd64.tar.gz", updated)
        self.assertIn("wacli_0.9.3_linux_arm64.tar.gz", updated)
        self.assertIn("wacli_0.9.3_linux_amd64.tar.gz", updated)
        self.assertNotIn("wacli-macos-universal.tar.gz", updated)
        self.assertNotIn("/archive/refs/tags/", updated)

    def test_inserts_target_stanzas_for_top_level_formula(self) -> None:
        text = '''class Sag < Formula
  desc "Command-line ElevenLabs TTS with mac-style flags"
  homepage "https://github.com/steipete/sag"
  url "https://github.com/steipete/sag/releases/download/v0.3.0/sag_0.3.0_darwin_universal.tar.gz"
  sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  license "MIT"

  on_linux do
    on_intel do
      url "https://github.com/steipete/sag/releases/download/v0.3.0/sag_0.3.0_linux_amd64.tar.gz"
      sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    end
  end

  def install
  end
end
'''

        updated = update_formula.insert_target_stanzas(
            text,
            "steipete/sag",
            "v0.3.1",
            "sag",
            "0.3.1",
            "{formula}_{version}_{target}.tar.gz",
            {},
        )

        self.assertIn("sag_0.3.1_darwin_arm64.tar.gz", updated)
        self.assertIn("sag_0.3.1_darwin_amd64.tar.gz", updated)
        self.assertIn("sag_0.3.1_linux_arm64.tar.gz", updated)
        self.assertIn("sag_0.3.1_linux_amd64.tar.gz", updated)
        self.assertNotIn("darwin_universal", updated)
        self.assertEqual(updated.count("on_linux do"), 1)

    def test_updates_cask_version_and_checksum_preserving_interpolated_url(self) -> None:
        text = '''cask "codexbar" do
  version "0.26.1"
  sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

  url "https://github.com/steipete/CodexBar/releases/download/v#{version}/CodexBar-macos-universal-#{version}.zip",
      verified: "github.com/steipete/CodexBar/"
end
'''

        updated = update_formula.update_version(text, "0.27.0")
        updated = update_formula.update_top_level_url_and_sha(
            updated,
            "https://github.com/steipete/CodexBar/releases/download/v0.27.0/CodexBar-macos-universal-0.27.0.zip",
            "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
            "0.27.0",
        )

        self.assertIn('version "0.27.0"', updated)
        self.assertIn('sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"', updated)
        self.assertIn("CodexBar-macos-universal-#{version}.zip", updated)

    def test_sha256_download_budget_is_documented(self) -> None:
        self.assertEqual(update_formula.DOWNLOAD_TIMEOUT_SECONDS, 30)

    def test_sha256_passes_timeout_and_hashes_the_body(self) -> None:
        payload = b"formula-asset"
        url = "https://github.com/openclaw/example/releases/download/v1.0.0/example.tar.gz"
        with mock.patch.object(
            update_formula.urllib.request,
            "urlopen",
            return_value=io.BytesIO(payload),
        ) as network:
            digest = update_formula.sha256(url)
        self.assertEqual(digest, hashlib.sha256(payload).hexdigest())
        network.assert_called_once()
        self.assertEqual(network.call_args.args[0].full_url, url)
        self.assertEqual(network.call_args.kwargs["timeout"], update_formula.DOWNLOAD_TIMEOUT_SECONDS)

    def test_sha256_timeout_fails_closed(self) -> None:
        url = "https://github.com/openclaw/example/releases/download/v1.0.0/example.tar.gz"
        with (
            mock.patch.object(
                update_formula.urllib.request,
                "urlopen",
                side_effect=TimeoutError("timed out"),
            ),
            self.assertRaisesRegex(SystemExit, r"timed out downloading .* after 30s"),
        ):
            update_formula.sha256(url)

    def test_sha256_urlerror_timeout_fails_closed(self) -> None:
        url = "https://github.com/openclaw/example/releases/download/v1.0.0/example.tar.gz"
        with (
            mock.patch.object(
                update_formula.urllib.request,
                "urlopen",
                side_effect=urllib.error.URLError(TimeoutError("timed out")),
            ),
            self.assertRaisesRegex(SystemExit, r"timed out downloading .* after 30s"),
        ):
            update_formula.sha256(url)


if __name__ == "__main__":
    unittest.main()
