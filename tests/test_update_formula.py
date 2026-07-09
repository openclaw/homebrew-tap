from __future__ import annotations

import importlib.util
import os
import pathlib
import tempfile
import unittest
from unittest import mock


ROOT = pathlib.Path(__file__).resolve().parents[1]
SCRIPT = ROOT / ".github" / "scripts" / "update_formula.py"
SPEC = importlib.util.spec_from_file_location("update_formula", SCRIPT)
assert SPEC and SPEC.loader
update_formula = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(update_formula)


class UpdateFormulaTest(unittest.TestCase):
    def test_validates_dispatch_identifiers(self) -> None:
        self.assertEqual(update_formula.validate_tap_token("gogcli", "formula"), "gogcli")
        self.assertEqual(update_formula.validate_repository("openclaw/gogcli"), "openclaw/gogcli")
        self.assertEqual(update_formula.validate_release_tag("v1.2.3-beta.1"), "v1.2.3-beta.1")

        invalid_values = (
            (update_formula.validate_tap_token, ("../../README", "formula")),
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
            self.assertEqual(options["cwd"], "/")
            self.assertEqual(options["env"]["GIT_CONFIG_GLOBAL"], "/dev/null")
            self.assertEqual(options["env"]["GIT_TERMINAL_PROMPT"], "0")
            self.assertNotIn("GH_TOKEN", options["env"])
            self.assertNotIn("GITHUB_TOKEN", options["env"])

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
        formula = (ROOT / "Formula" / "crabbox.rb").read_text()
        hashes = {
            "darwin_amd64": "1" * 64,
            "darwin_arm64": "2" * 64,
            "linux_amd64": "3" * 64,
            "linux_arm64": "4" * 64,
        }

        updated = update_formula.render_verified_target_formula(
            formula,
            "openclaw/crabbox",
            "v0.36.1",
            "crabbox",
            "0.36.1",
            "{formula}_{version}_{target}.tar.gz",
            {},
            hashes,
        )

        self.assertEqual(updated.count("define_method(:install) do"), 4)
        self.assertEqual(updated.count('bin.install "crabbox"'), 4)
        self.assertEqual(updated.count('bin.install "crabbox-apple-vm-helper"'), 4)
        for target, digest in hashes.items():
            self.assertIn(f"crabbox_#{{version}}_{target}.tar.gz", updated)
            self.assertEqual(updated.count(digest), 1)

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


if __name__ == "__main__":
    unittest.main()
