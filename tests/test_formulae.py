from __future__ import annotations

import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


class FormulaTest(unittest.TestCase):
    def test_crawlbar_installs_trusted_release_app(self) -> None:
        text = (ROOT / "Formula" / "crawlbar.rb").read_text()
        self.assertIn("/releases/download/", text)
        self.assertIn("CrawlBar-v", text)
        self.assertIn("Developer ID Application: OpenClaw Foundation (FWJYW4S8P8)", text)
        self.assertNotIn("/archive/refs/tags/", text)
        self.assertNotIn('system "swift"', text)
        self.assertNotIn('head "', text)

    def test_wacli_head_build_declares_go(self) -> None:
        text = (ROOT / "Formula" / "wacli.rb").read_text()
        self.assertIn('depends_on "go" => :build if build.head?', text)


if __name__ == "__main__":
    unittest.main()
