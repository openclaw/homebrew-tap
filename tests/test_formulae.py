from __future__ import annotations

import pathlib
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]


class FormulaTest(unittest.TestCase):
    def test_wacli_head_build_declares_go(self) -> None:
        text = (ROOT / "Formula" / "wacli.rb").read_text()
        self.assertIn('depends_on "go" => :build if build.head?', text)


if __name__ == "__main__":
    unittest.main()
