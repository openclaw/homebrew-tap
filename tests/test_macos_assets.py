from __future__ import annotations

import hashlib
import json
import os
import pathlib
import re
import tempfile
import unittest
from unittest import mock

from test_reconcile_formulae import reconcile_formulae
from test_update_formula import ROOT, platform_install_formula, update_formula


def macos_assets(version: str = "4.4.1") -> dict[str, dict[str, str]]:
    return {
        target: {"name": f"peekaboo-macos-{arch}.tar.gz", "sha256": hashlib.sha256((version + target).encode()).hexdigest()}
        for target, arch in (("darwin_arm64", "arm64"), ("darwin_amd64", "x86_64"))
    }


class MacOSAssetsTest(unittest.TestCase):
    def setUp(self) -> None:
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.previous = pathlib.Path.cwd()
        self.addCleanup(os.chdir, self.previous)
        self.root = pathlib.Path(self.directory.name)
        (self.root / "Formula").mkdir()
        self.path = self.root / "Formula/peekaboo.rb"
        self.original = (ROOT / "Formula/peekaboo.rb").read_text()
        self.path.write_text(self.original)
        os.chdir(self.root)

    def update(self, assets: dict[str, dict[str, str]], version: str = "4.4.1") -> str:
        arguments = [
            "--formula", "peekaboo", "--repository", "openclaw/Peekaboo",
            "--tag", f"v{version}", "--assets-json", json.dumps(assets),
        ]
        expected = {
            update_formula.explicit_asset_url("openclaw/Peekaboo", f"v{version}", item["name"]): item["sha256"]
            for item in assets.values()
        }
        with mock.patch.object(update_formula, "sha256", side_effect=expected.__getitem__) as download:
            self.assertEqual(update_formula.main(arguments), 0)
        self.assertCountEqual([call.args[0] for call in download.call_args_list], expected)
        return self.path.read_text()

    def test_accepts_only_complete_darwin_pair_or_four_targets(self) -> None:
        assets = macos_assets()
        self.assertEqual(update_formula.parse_explicit_assets(json.dumps(assets)), assets)
        for targets in ({}, {"darwin_arm64"}, {"linux_arm64", "linux_amd64"},
                        {"darwin_arm64", "darwin_amd64", "linux_arm64"},
                        {"darwin_arm64", "darwin_amd64", "windows_amd64"}):
            with self.subTest(targets=targets), self.assertRaisesRegex(SystemExit, "must contain exactly"):
                update_formula.parse_explicit_assets(json.dumps({target: next(iter(assets.values())) for target in targets}))

    def test_converts_then_updates_pair_without_changing_maintained_content(self) -> None:
        first = self.update(macos_assets())
        self.assertIn("url on_arch_conditional(", first)
        self.assertIn("sha256 on_arch_conditional(", first)
        self.assertNotIn("on_linux", first)
        self.assertNotIn("on_macos", first)
        self.assertIn("depends_on macos: :sequoia", first)
        self.assertEqual(first.split('  license "MIT"', 1)[1], self.original.split('  license "MIT"', 1)[1])
        self.assertEqual(self.update(macos_assets()), first)
        second = self.update(macos_assets("4.4.2"), "4.4.2")
        expected = first.replace("/v4.4.1/", "/v4.4.2/")
        for target, item in macos_assets().items():
            expected = expected.replace(item["sha256"], macos_assets("4.4.2")[target]["sha256"])
        self.assertEqual(second, expected)

    def test_formatted_pair_can_be_reconciled_and_updated(self) -> None:
        first = self.update(macos_assets())
        for arm_spacing, intel_spacing in (("   ", " "), ("\t", "\t")):
            with self.subTest(arm=arm_spacing, intel=intel_spacing):
                formatted = re.sub(r'arm:[ \t]*(?=")', "arm:" + arm_spacing, first)
                formatted = re.sub(r'intel:[ \t]*(?=")', "intel:" + intel_spacing, formatted)
                self.path.write_text(formatted)
                info = reconcile_formulae.parse_formula(self.path)
                self.assertEqual(info.current_tag, "v4.4.1")
                self.assertEqual(info.update_options, ())
                expected = formatted.replace("/v4.4.1/", "/v4.4.2/")
                for target, item in macos_assets().items():
                    expected = expected.replace(item["sha256"], macos_assets("4.4.2")[target]["sha256"])
                self.assertEqual(self.update(macos_assets("4.4.2"), "4.4.2"), expected)

    def test_digest_failure_leaves_existing_or_missing_formula_untouched(self) -> None:
        assets = macos_assets()
        for existing in (True, False):
            if not existing:
                self.path.unlink()
            for target, bad in assets.items():
                with self.subTest(existing=existing, target=target):
                    def digest(url: str) -> str:
                        item = next(item for item in assets.values() if url.endswith("/" + item["name"]))
                        return "f" * 64 if item is bad else item["sha256"]

                    with mock.patch.object(update_formula, "sha256", side_effect=digest):
                        with self.assertRaisesRegex(SystemExit, "SHA-256 mismatch"):
                            update_formula.main([
                                "--formula", "peekaboo", "--repository", "openclaw/Peekaboo",
                                "--tag", "v4.4.1", "--assets-json", json.dumps(assets),
                            ])
                    self.assertEqual(self.path.read_text() if existing else self.path.exists(), self.original if existing else False)

    def test_creates_macos_only_formula_after_both_downloads(self) -> None:
        self.path.unlink()
        rendered = self.update(macos_assets())
        self.assertIn("depends_on :macos", rendered)
        self.assertNotIn("on_linux", rendered)
        self.assertNotIn("0" * 64, rendered)
        self.assertEqual(len(update_formula.formula_text.iter_primary_url_sha_pairs(rendered)), 2)

    def test_pair_does_not_remove_existing_linux_formula_content(self) -> None:
        original = platform_install_formula().replace('  license "MIT"', '  license "MIT"\n  depends_on :macos')
        self.path.write_text(original)
        with self.assertRaisesRegex(SystemExit, "require one top-level archive"):
            self.update(macos_assets())
        self.assertEqual(self.path.read_text(), original)

    def test_pair_rejects_architecture_metadata_nested_in_a_platform_block(self) -> None:
        first = self.update(macos_assets())
        metadata, suffix = first.split('  license "MIT"', 1)
        header, metadata = metadata.split("  url ", 1)
        original = header + "  on_macos do\n" + "\n".join("  " + line for line in ("  url " + metadata).splitlines())
        original += '\n  end\n  license "MIT"' + suffix
        self.path.write_text(original)
        with self.assertRaisesRegex(SystemExit, "require one top-level archive"):
            self.update(macos_assets())
        self.assertEqual(self.path.read_text(), original)

    def test_reconciles_generated_pair_and_preserves_resource_metadata(self) -> None:
        resource = (
            '  resource "helper" do\n'
            '    url "https://github.com/openclaw/Peekaboo/releases/download/v0.1.0/helper.tar.gz"\n'
            f'    sha256 "{"a" * 64}"\n'
            '  end\n\n'
        )
        self.path.write_text(self.original.replace("  def install", resource + "  def install"))
        first = self.update(macos_assets())
        info = reconcile_formulae.parse_formula(self.path)
        self.assertEqual(info.current_tag, "v4.4.1")
        self.assertEqual(info.repository, "openclaw/Peekaboo")
        with mock.patch.object(update_formula, "sha256", return_value="e" * 64) as download:
            self.assertEqual(update_formula.main([
                "--formula", info.name, "--repository", info.repository,
                "--tag", "v4.4.2", *info.update_options,
            ]), 0)
        self.assertEqual(download.call_count, 2)
        self.assertTrue(all("/v4.4.2/peekaboo-macos-" in call.args[0] for call in download.call_args_list))
        updated = self.path.read_text()
        self.assertIn(resource, updated)
        expected = first.replace("/v4.4.1/", "/v4.4.2/")
        for item in macos_assets().values():
            expected = expected.replace(item["sha256"], "e" * 64)
        self.assertEqual(updated, expected)

    def test_reconciles_encoded_targets_without_filename_inference(self) -> None:
        for names in (("a.tar.gz", "b.tar.gz"), ("a-4.4.1.tar.gz", "different-4.4.1-build.tar.gz"),
                      ("intel-named-4.4.1.tar.gz", "macos-arm64.tar.gz")):
            with self.subTest(names=names):
                self.path.write_text(self.original)
                assets = macos_assets()
                for item, name in zip(assets.values(), names):
                    item["name"] = name
                first = self.update(assets)
                info = reconcile_formulae.parse_formula(self.path)
                self.assertEqual(info.update_options, ())
                expected_urls = {
                    target: update_formula.explicit_asset_url("openclaw/Peekaboo", "v4.4.2", item["name"].replace("4.4.1", "4.4.2"))
                    for target, item in assets.items()
                }
                downloads = {url: assets[target]["sha256"] for target, url in expected_urls.items()}
                with mock.patch.object(update_formula, "sha256", side_effect=downloads.__getitem__) as download:
                    self.assertEqual(update_formula.main([
                        "--formula", info.name, "--repository", info.repository, "--tag", "v4.4.2", *info.update_options,
                    ]), 0)
                self.assertCountEqual([call.args[0] for call in download.call_args_list], downloads)
                pairs = update_formula.formula_text.iter_primary_url_sha_pairs(self.path.read_text())
                self.assertEqual({pair.target: pair.url for pair in pairs}, expected_urls)
                self.assertEqual(self.path.read_text(), first.replace("4.4.1", "4.4.2"))

    def test_reconciliation_second_download_failure_leaves_formula_untouched(self) -> None:
        first = self.update(macos_assets())
        info = reconcile_formulae.parse_formula(self.path)
        with mock.patch.object(update_formula, "sha256", side_effect=["e" * 64, SystemExit("download failed")]) as download:
            with self.assertRaisesRegex(SystemExit, "download failed"):
                update_formula.main([
                    "--formula", info.name, "--repository", info.repository, "--tag", "v4.4.2", *info.update_options,
                ])
        self.assertEqual(download.call_count, 2)
        self.assertEqual(self.path.read_text(), first)

    def test_explicit_template_uses_encoded_targets(self) -> None:
        assets = macos_assets()
        assets["darwin_arm64"]["name"] = "macos-x86_64.tar.gz"
        assets["darwin_amd64"]["name"] = "macos-arm64.tar.gz"
        self.update(assets)
        with mock.patch.object(update_formula, "sha256", return_value="e" * 64):
            self.assertEqual(update_formula.main([
                "--formula", "peekaboo", "--repository", "openclaw/Peekaboo", "--tag", "v4.4.2",
                "--artifact-template", "cli-{target}-{version}.tar.gz",
            ]), 0)
        pairs = update_formula.formula_text.iter_primary_url_sha_pairs(self.path.read_text())
        self.assertEqual({pair.target: pair.url for pair in pairs}, {
            target: f"https://github.com/openclaw/Peekaboo/releases/download/v4.4.2/cli-{target}-4.4.2.tar.gz"
            for target in assets
        })

    def test_reconciliation_rejects_incoherent_pair_before_downloading(self) -> None:
        first = self.update(macos_assets())
        for wrong in (first.replace("/v4.4.1/", "/v4.3.0/", 1),
                      first.replace("/openclaw/Peekaboo/releases/", "/openclaw/other/releases/", 1)):
            with self.subTest(text=wrong):
                self.path.write_text(wrong)
                with mock.patch.object(update_formula, "sha256") as download, self.assertRaises(SystemExit):
                    update_formula.main([
                        "--formula", "peekaboo", "--repository", "openclaw/Peekaboo", "--tag", "v4.4.2",
                    ])
                download.assert_not_called()
                self.assertEqual(self.path.read_text(), wrong)

    def test_explicit_single_archive_restores_universal_then_accepts_thin_again(self) -> None:
        resource = (
            '  resource "helper" do\n'
            '    url "https://github.com/openclaw/Peekaboo/releases/download/v0.1.0/helper.tar.gz"\n'
            f'    sha256 "{"a" * 64}"\n'
            '  end\n\n'
        )
        for argument, value in (
            ("--macos-artifact", "peekaboo-macos-universal.tar.gz"),
            ("--artifact-url", "https://github.com/openclaw/Peekaboo/releases/download/{tag}/peekaboo-macos-universal.tar.gz"),
        ):
            for explicit_version in (False, True):
                with self.subTest(argument=argument, explicit_version=explicit_version):
                    original = self.original.replace("  def install", resource + "  def install")
                    if explicit_version:
                        original = original.replace('  sha256 "', '  version "4.4.0"\n  sha256 "', 1)
                    self.path.write_text(original)
                    self.update(macos_assets())
                    arguments = [
                        "--formula", "peekaboo", "--repository", "openclaw/Peekaboo", "--tag", "v4.4.0",
                        argument, value,
                    ]
                    url = "https://github.com/openclaw/Peekaboo/releases/download/v4.4.0/peekaboo-macos-universal.tar.gz"
                    with mock.patch.object(update_formula, "sha256", side_effect={url: "c" * 64}.__getitem__) as download:
                        self.assertEqual(update_formula.main(arguments), 0)
                    download.assert_called_once_with(url)
                    restored = self.path.read_text()
                    self.assertNotIn("on_arch_conditional", restored)
                    pairs = update_formula.formula_text.iter_primary_url_sha_pairs(restored)
                    self.assertEqual([(pair.url, pair.sha) for pair in pairs], [(url, "c" * 64)])
                    self.assertEqual(restored.split('  license "MIT"', 1)[1], original.split('  license "MIT"', 1)[1])
                    if explicit_version:
                        self.assertIn('  version "4.4.0"\n', restored)
                    with mock.patch.object(update_formula, "sha256", return_value="c" * 64):
                        self.assertEqual(update_formula.main(arguments), 0)
                    self.assertEqual(self.path.read_text(), restored)
                    info = reconcile_formulae.parse_formula(self.path)
                    self.assertEqual(info.current_tag, "v4.4.0")
                    with mock.patch.object(update_formula, "sha256", return_value="d" * 64) as download:
                        self.assertEqual(update_formula.main([
                            "--formula", info.name, "--repository", info.repository, "--tag", "v4.4.2", *info.update_options,
                        ]), 0)
                    download.assert_called_once_with(url.replace("4.4.0", "4.4.2"))
                    reconverted = self.update(macos_assets("4.4.3"), "4.4.3")
                    self.assertIn("url on_arch_conditional(", reconverted)
                    self.assertEqual(reconverted.split('  license "MIT"', 1)[1], original.split('  license "MIT"', 1)[1])

    def test_universal_transition_download_failure_preserves_thin_formula(self) -> None:
        first = self.update(macos_assets())
        with mock.patch.object(update_formula, "sha256", side_effect=SystemExit("download failed")) as download:
            with self.assertRaisesRegex(SystemExit, "download failed"):
                update_formula.main([
                    "--formula", "peekaboo", "--repository", "openclaw/Peekaboo", "--tag", "v4.4.0",
                    "--macos-artifact", "peekaboo-macos-universal.tar.gz",
                ])
        download.assert_called_once_with(
            "https://github.com/openclaw/Peekaboo/releases/download/v4.4.0/peekaboo-macos-universal.tar.gz",
        )
        self.assertEqual(self.path.read_text(), first)


if __name__ == "__main__":
    unittest.main()
