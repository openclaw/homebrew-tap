from __future__ import annotations

import contextlib
import importlib.util
import io
import json
import os
import pathlib
import tempfile
import unittest
import urllib.error
from unittest import mock

ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("combined_updater", ROOT / ".github/scripts/update_formula.py")
assert SPEC and SPEC.loader
updater = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(updater)

CASK = '''cask "example" do
  version "1.2.2"
  sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  url "https://github.com/openclaw/example/releases/download/v#{version}/example.zip"
end
'''


class CombinedUpdateTest(unittest.TestCase):
    def test_combined_updates_prepare_both_files_before_writing(self) -> None:
        for mode in ("legacy", "explicit"):
            for existing in (False, True):
                for failure in (None, "download", "missing-cask", "invalid-cask", "invalid-artifact"):
                    with self.subTest(mode=mode, existing=existing, failure=failure), tempfile.TemporaryDirectory() as directory:
                        root = pathlib.Path(directory)
                        (root / "Formula").mkdir()
                        (root / "Casks").mkdir()
                        formula = root / "Formula/example.rb"
                        cask = root / "Casks/example.rb"
                        if existing:
                            formula.write_text(updater.formula_text.seed_formula(
                                "example", "openclaw/example", "1.2.2", "Example", "{formula}_{version}_{target}.tar.gz",
                            ))
                        if failure != "missing-cask":
                            cask.write_text('cask "example" do\nend\n' if failure == "invalid-cask" else CASK)
                        before = {p.relative_to(root): p.read_bytes() for p in root.rglob("*.rb")}
                        arguments = [
                            "--formula", "example", "--tag", "v1.2.3", "--repository", "openclaw/example",
                            "--cask", "example", "--cask-artifact",
                            "bad/name.zip" if failure == "invalid-artifact" else "example.zip",
                        ]
                        if mode == "explicit":
                            arguments += ["--assets-json", json.dumps({
                                target: {"name": f"example_1.2.3_{target}.tar.gz", "sha256": "b" * 64}
                                for target in updater.RELEASE_TARGETS
                            })]

                        downloads = []

                        def download(url: str) -> str:
                            self.assertEqual({p.relative_to(root): p.read_bytes() for p in root.rglob("*.rb")}, before)
                            downloads.append(url)
                            if url.endswith("/example.zip"):
                                if failure == "download":
                                    raise urllib.error.URLError("cask download failed")
                                return "c" * 64
                            return "b" * 64

                        previous = pathlib.Path.cwd()
                        os.chdir(root)
                        try:
                            with mock.patch.object(updater, "sha256", side_effect=download), contextlib.redirect_stdout(io.StringIO()):
                                if failure:
                                    with self.assertRaises((SystemExit, urllib.error.URLError)):
                                        updater.main(arguments)
                                else:
                                    self.assertEqual(updater.main(arguments), 0)
                        finally:
                            os.chdir(previous)
                        if failure:
                            self.assertEqual({p.relative_to(root): p.read_bytes() for p in root.rglob("*.rb")}, before)
                        else:
                            self.assertEqual(len(downloads), 5)
                            self.assertEqual(formula.read_text().count('sha256 "' + 'b' * 64), 4)
                            self.assertIn('version "1.2.3"', formula.read_text())
                            self.assertIn('version "1.2.3"', cask.read_text())
                            self.assertIn('sha256 "' + 'c' * 64, cask.read_text())


if __name__ == "__main__":
    unittest.main()
