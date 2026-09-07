from __future__ import annotations

import contextlib
import hashlib
import importlib.util
import json
import io
import os
import pathlib
import sys
import tempfile
import unittest
from unittest import mock


ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / ".github" / "scripts" / "reconcile_formulae.py"
SPEC = importlib.util.spec_from_file_location("reconcile_formulae", SCRIPT)
assert SPEC and SPEC.loader
reconcile_formulae = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = reconcile_formulae
SPEC.loader.exec_module(reconcile_formulae)


def formula_text(version: str = "1.2.3") -> str:
    return f'''class Example < Formula
  desc "Example"
  homepage "https://github.com/openclaw/example"
  version "{version}"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/example/releases/download/v{version}/example_v{version}_darwin_arm64.tar.gz"
      sha256 "{'a' * 64}"
    else
      url "https://github.com/openclaw/example/releases/download/v{version}/example_v{version}_darwin_amd64.tar.gz"
      sha256 "{'b' * 64}"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/example/releases/download/v{version}/example_v{version}_linux_arm64.tar.gz"
      sha256 "{'c' * 64}"
    else
      url "https://github.com/openclaw/example/releases/download/v{version}/example_v{version}_linux_amd64.tar.gz"
      sha256 "{'d' * 64}"
    end
  end
end
'''


class ReconcileFormulaeTest(unittest.TestCase):
    def make_tap(self, text: str = formula_text()) -> tuple[tempfile.TemporaryDirectory[str], pathlib.Path]:
        directory = tempfile.TemporaryDirectory()
        root = pathlib.Path(directory.name)
        (root / "Formula").mkdir()
        (root / "Formula" / "example.rb").write_text(text)
        return directory, root

    def test_semver_orders_prereleases_and_ignores_build_metadata(self) -> None:
        stable = reconcile_formulae.parse_semver("v1.2.3")
        prerelease = reconcile_formulae.parse_semver("1.2.3-rc.1")
        newer = reconcile_formulae.parse_semver("1.2.4+build.7")
        self.assertGreater(stable.compare(prerelease), 0)
        self.assertLess(stable.compare(newer), 0)
        self.assertEqual(stable.compare(reconcile_formulae.parse_semver("1.2.3+other")), 0)

    def test_parses_homepage_version_and_custom_artifact_template(self) -> None:
        directory, root = self.make_tap()
        self.addCleanup(directory.cleanup)
        info = reconcile_formulae.parse_formula(root / "Formula" / "example.rb")
        self.assertEqual(info.repository, "openclaw/example")
        self.assertEqual(info.current_tag, "v1.2.3")
        self.assertEqual(
            info.update_options,
            ("--artifact-template", "example_v{version}_{target}.tar.gz"),
        )

    def test_every_checked_in_formula_has_a_reconcilable_release_shape(self) -> None:
        formulae = sorted((ROOT / "Formula").glob("*.rb"))
        self.assertTrue(formulae)
        for path in formulae:
            with self.subTest(formula=path.stem):
                info = reconcile_formulae.parse_formula(path)
                self.assertEqual(info.name, path.stem)
                self.assertTrue(info.update_options)

    def test_ocm_reconciliation_preserves_three_targets_and_installed_binary_policy(self) -> None:
        original = (ROOT / "Formula" / "ocm.rb").read_text()
        info = reconcile_formulae.parse_formula(ROOT / "Formula" / "ocm.rb")
        newer = f"v{info.current_version.major}.{info.current_version.minor + 1}.0"
        targets = ("aarch64-apple-darwin", "x86_64-apple-darwin", "x86_64-unknown-linux-gnu")
        urls = [
            f"https://github.com/openclaw/ocm/releases/download/{newer}/ocm-{target}.tar.gz"
            for target in targets
        ]
        expected = original.replace(f'version "{info.current_tag[1:]}"', f'version "{newer[1:]}"')
        for pair in reconcile_formulae.update_formula.iter_url_sha_pairs(original):
            url = pair.group("url").replace(f"/{info.current_tag}/", f"/{newer}/")
            self.assertIn(url, urls)
            expected = expected.replace(pair.group("url"), url).replace(
                pair.group("sha"), hashlib.sha256(url.encode()).hexdigest(),
            )

        for dry_run in (False, True):
            for failed_download in (False, True):
                with self.subTest(dry_run=dry_run, failed_download=failed_download):
                    directory, root = self.make_tap()
                    self.addCleanup(directory.cleanup)
                    ocm = root / "Formula" / "ocm.rb"
                    ocm.write_text(original)
                    downloads = []

                    def response(request, **kwargs):
                        url = request.full_url
                        if url == "https://api.github.com/repos/openclaw/ocm/releases/latest":
                            return io.BytesIO(json.dumps({"tag_name": newer}).encode())
                        if url == "https://api.github.com/repos/openclaw/example/releases/latest":
                            return io.BytesIO(b'{"tag_name":"v1.2.3"}')
                        self.assertIn(url, urls)
                        downloads.append(url)
                        if failed_download and url == urls[-1]:
                            raise reconcile_formulae.urllib.error.URLError("fixture download failed")
                        return io.BytesIO(url.encode())

                    def run(command, *, cwd, check):
                        self.assertTrue(check)
                        self.assertEqual(pathlib.Path(command[1]).name, "update_formula.py")
                        previous_directory = pathlib.Path.cwd()
                        os.chdir(cwd)
                        try:
                            self.assertEqual(reconcile_formulae.update_formula.main(command[2:]), 0)
                        finally:
                            os.chdir(previous_directory)

                    output = io.StringIO()
                    with (
                        mock.patch.object(reconcile_formulae.urllib.request, "urlopen", side_effect=response),
                        mock.patch.object(reconcile_formulae.subprocess, "run", side_effect=run),
                        contextlib.redirect_stdout(output),
                    ):
                        summary = reconcile_formulae.reconcile(root, None, dry_run)
                    self.assertCountEqual(downloads, urls)
                    self.assertEqual(summary, reconcile_formulae.Summary(
                        scanned=2, current=1, drift=1,
                        updated=0 if failed_download else 1,
                        failed=1 if failed_download else 0,
                    ))
                    self.assertEqual(ocm.read_text(), original if dry_run or failed_download else expected)
                    self.assertEqual((root / "Formula" / "example.rb").read_text(), formula_text())
                    if dry_run and not failed_download:
                        self.assertIn("WOULD UPDATE ocm", output.getvalue())
                        for line in expected.splitlines():
                            if line.strip().startswith(('url "', 'sha256 "', 'version "')):
                                self.assertIn("+" + line, output.getvalue())

    def test_crabbox_reconciliation_uses_published_stable_releases_in_all_scan_modes(self) -> None:
        original = (ROOT / "Formula" / "crabbox.rb").read_text()
        info = reconcile_formulae.parse_formula(ROOT / "Formula" / "crabbox.rb")
        newer = f"v{info.current_version.major}.{info.current_version.minor + 1}.0"
        cases = (
            ("published", newer, False, False, "updated"),
            ("draft", newer, True, False, "skipped"),
            ("prerelease", newer, False, True, "skipped"),
            ("prerelease-tag", newer + "-rc.1", False, False, "skipped"),
            ("no-release", None, False, False, "skipped"),
            ("current", info.current_tag, False, False, "current"),
            ("downgrade", "v0.0.0", False, False, "refused"),
        )
        for selected in (None, "crabbox"):
            for dry_run in (False, True):
                for label, tag, draft, prerelease, outcome in cases:
                    with self.subTest(selected=selected, dry_run=dry_run, release=label):
                        directory, root = self.make_tap()
                        self.addCleanup(directory.cleanup)
                        crabbox = root / "Formula" / "crabbox.rb"
                        crabbox.write_text(original)
                        downloads = []

                        def response(request, **kwargs):
                            url = request.full_url
                            if url == "https://api.github.com/repos/openclaw/crabbox/releases/latest":
                                if tag is None:
                                    raise reconcile_formulae.urllib.error.HTTPError(url, 404, "no release", {}, None)
                                return io.BytesIO(json.dumps({
                                    "tag_name": tag, "draft": draft, "prerelease": prerelease,
                                }).encode())
                            if url == "https://api.github.com/repos/openclaw/example/releases/latest":
                                return io.BytesIO(b'{"tag_name":"v1.2.3","draft":false,"prerelease":false}')
                            expected = [
                                f"https://github.com/openclaw/crabbox/releases/download/{newer}/"
                                f"crabbox_{newer[1:]}_{target}.tar.gz"
                                for target in reconcile_formulae.update_formula.RELEASE_TARGETS
                            ]
                            self.assertIn(url, expected)
                            downloads.append(url)
                            return io.BytesIO(url.encode())

                        def run(command, *, cwd, check):
                            self.assertTrue(check)
                            self.assertEqual(pathlib.Path(command[1]).name, "update_formula.py")
                            previous_directory = pathlib.Path.cwd()
                            os.chdir(cwd)
                            try:
                                self.assertEqual(reconcile_formulae.update_formula.main(command[2:]), 0)
                            finally:
                                os.chdir(previous_directory)

                        output = io.StringIO()
                        with (
                            mock.patch.object(reconcile_formulae.urllib.request, "urlopen", side_effect=response),
                            mock.patch.object(reconcile_formulae.subprocess, "run", side_effect=run) as update,
                            contextlib.redirect_stdout(output),
                        ):
                            summary = reconcile_formulae.reconcile(root, selected, dry_run)
                        expected_summary = reconcile_formulae.Summary(scanned=1 if selected else 2)
                        if not selected:
                            expected_summary.current = 1
                        setattr(expected_summary, outcome, getattr(expected_summary, outcome) + 1)
                        if outcome == "updated":
                            expected_summary.drift = 1
                            self.assertEqual(update.call_count, 1)
                            self.assertEqual(len(downloads), 4)
                            expected = original
                            for match in reconcile_formulae.update_formula.iter_url_sha_pairs(original):
                                target = reconcile_formulae.update_formula.classify_target(match.group("url"), {}, info.current_tag[1:])
                                url = next(url for url in downloads if url.endswith(f"_{target}.tar.gz"))
                                expected = expected.replace(match.group("url"), url).replace(
                                    match.group("sha"), hashlib.sha256(url.encode()).hexdigest(),
                                )
                            if dry_run:
                                self.assertIn("WOULD UPDATE crabbox", output.getvalue())
                                for line in expected.splitlines():
                                    if line.strip().startswith(('url "', 'sha256 "')):
                                        self.assertIn("+" + line, output.getvalue())
                            self.assertEqual(crabbox.read_text(), original if dry_run else expected)
                        else:
                            update.assert_not_called()
                            self.assertEqual(downloads, [])
                            self.assertEqual(crabbox.read_text(), original)
                        self.assertEqual(summary, expected_summary)
                        self.assertEqual((root / "Formula" / "example.rb").read_text(), formula_text())

    def test_crabbox_and_another_stale_formula_both_reconcile(self) -> None:
        directory, root = self.make_tap()
        self.addCleanup(directory.cleanup)
        crabbox = root / "Formula" / "crabbox.rb"
        crabbox.write_bytes((ROOT / "Formula" / "crabbox.rb").read_bytes())
        lookup = mock.Mock(return_value=reconcile_formulae.Release("v99.0.0", False, False))
        def updater(root: pathlib.Path, info: reconcile_formulae.FormulaInfo, tag: str, dry_run: bool) -> None:
            self.assertFalse(dry_run)
            previous_directory = pathlib.Path.cwd()
            os.chdir(root)
            try:
                self.assertEqual(reconcile_formulae.update_formula.main([
                    "--formula", info.name, "--tag", tag, "--repository", info.repository, *info.update_options,
                ]), 0)
            finally:
                os.chdir(previous_directory)

        with mock.patch.object(reconcile_formulae.update_formula, "sha256", return_value="e" * 64) as download:
            summary = reconcile_formulae.reconcile(root, None, False, lookup, updater)
        self.assertEqual(summary, reconcile_formulae.Summary(scanned=2, drift=2, updated=2))
        self.assertCountEqual(lookup.call_args_list, [mock.call("openclaw/crabbox"), mock.call("openclaw/example")])
        self.assertEqual(download.call_count, 8)
        for name in ("crabbox", "example"):
            updated = (root / "Formula" / f"{name}.rb").read_text()
            self.assertEqual(updated.count(f"https://github.com/openclaw/{name}/releases/download/v99.0.0/"), 4)
            self.assertEqual(updated.count('sha256 "' + "e" * 64 + '"'), 4)

    def test_no_drift_does_not_run_updater_or_change_formula(self) -> None:
        directory, root = self.make_tap()
        self.addCleanup(directory.cleanup)
        path = root / "Formula" / "example.rb"
        before = path.read_text()
        updates: list[str] = []
        summary = reconcile_formulae.reconcile(
            root,
            None,
            False,
            release_lookup=lambda _: reconcile_formulae.Release("v1.2.3", False, False),
            updater=lambda _root, _info, tag, _dry_run: updates.append(tag),
        )
        self.assertEqual(summary.current, 1)
        self.assertEqual(summary.drift, 0)
        self.assertEqual(updates, [])
        self.assertEqual(path.read_text(), before)

    def test_dry_run_detects_exactly_one_stale_formula(self) -> None:
        directory, root = self.make_tap()
        self.addCleanup(directory.cleanup)
        second = formula_text().replace("Example", "Current").replace(
            "openclaw/example", "openclaw/current"
        ).replace("example", "current")
        (root / "Formula" / "current.rb").write_text(second)
        updates: list[tuple[str, str, bool]] = []

        def latest(repository: str) -> reconcile_formulae.Release:
            tag = "v1.2.4" if repository == "openclaw/example" else "v1.2.3"
            return reconcile_formulae.Release(tag, False, False)

        summary = reconcile_formulae.reconcile(
            root,
            None,
            True,
            release_lookup=latest,
            updater=lambda _root, info, tag, dry_run: updates.append((info.name, tag, dry_run)),
        )
        self.assertEqual(summary.scanned, 2)
        self.assertEqual(summary.drift, 1)
        self.assertEqual(summary.updated, 1)
        self.assertEqual(updates, [("example", "v1.2.4", True)])

    def test_refuses_downgrade(self) -> None:
        directory, root = self.make_tap()
        self.addCleanup(directory.cleanup)
        updates: list[str] = []
        summary = reconcile_formulae.reconcile(
            root,
            None,
            False,
            release_lookup=lambda _: reconcile_formulae.Release("v1.2.2", False, False),
            updater=lambda _root, _info, tag, _dry_run: updates.append(tag),
        )
        self.assertEqual(summary.refused, 1)
        self.assertEqual(summary.drift, 0)
        self.assertEqual(updates, [])

    def test_skips_prerelease_even_if_release_flag_is_wrong(self) -> None:
        directory, root = self.make_tap()
        self.addCleanup(directory.cleanup)
        updates: list[str] = []
        summary = reconcile_formulae.reconcile(
            root,
            None,
            False,
            release_lookup=lambda _: reconcile_formulae.Release("v1.2.4-rc.1", False, False),
            updater=lambda _root, _info, tag, _dry_run: updates.append(tag),
        )
        self.assertEqual(summary.skipped, 1)
        self.assertEqual(updates, [])

    def test_unparseable_formula_does_not_block_later_formulae(self) -> None:
        directory, root = self.make_tap("class Broken < Formula\nend\n")
        self.addCleanup(directory.cleanup)
        (root / "Formula" / "working.rb").write_text(
            formula_text().replace("Example", "Working").replace(
                "openclaw/example", "openclaw/working"
            ).replace("example", "working")
        )
        summary = reconcile_formulae.reconcile(
            root,
            None,
            False,
            release_lookup=lambda _: reconcile_formulae.Release("v1.2.3", False, False),
        )
        self.assertEqual(summary.scanned, 2)
        self.assertEqual(summary.skipped, 1)
        self.assertEqual(summary.current, 1)

    def test_invalid_artifact_template_does_not_block_later_formulae(self) -> None:
        bad = '''class Example < Formula
  desc "Example"
  homepage "https://github.com/openclaw/example"
  version "1.2.3"
  license "MIT"

  url "https://github.com/openclaw/example/releases/download/v1.2.3/example_v1.2.3_{oops}.tar.gz"
  sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
end
'''
        directory, root = self.make_tap(bad)
        self.addCleanup(directory.cleanup)
        bad_path = root / "Formula" / "example.rb"
        (root / "Formula" / "working.rb").write_text(
            formula_text().replace("Example", "Working").replace(
                "openclaw/example", "openclaw/working"
            ).replace("example", "working")
        )
        with self.assertRaises(ValueError):
            reconcile_formulae.parse_formula(bad_path)
        summary = reconcile_formulae.reconcile(
            root,
            None,
            False,
            release_lookup=lambda _: reconcile_formulae.Release("v1.2.3", False, False),
        )
        self.assertEqual(summary.scanned, 2)
        self.assertEqual(summary.skipped, 1)
        self.assertEqual(summary.current, 1)


if __name__ == "__main__":
    unittest.main()
