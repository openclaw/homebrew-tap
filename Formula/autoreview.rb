# frozen_string_literal: true

# Package the published helper without altering its source fingerprint.
class Autoreview < Formula
  desc "Structured code review with local AI command-line tools"
  homepage "https://github.com/openclaw/agent-skills"
  url "https://github.com/openclaw/agent-skills/releases/download/v0.6.0/source-0.6.0.tar.gz"
  sha256 "42aaf4cd9c49b561e81f744e9216928d9076f7d61a2e1f3c9d8c61e3696115f4"
  license "MIT"

  depends_on "git"
  depends_on "python@3.14"

  def install
    (libexec/"skills").install "skills/autoreview"
    libexec.install ".release-version", "LICENSE"
    # Keep the published helper bytes intact: --version fingerprints this file.
    (bin/"autoreview").write_env_script formula_opt_bin("python@3.14")/"python3.14",
                                        "\"#{libexec}/skills/autoreview/scripts/autoreview\"", {}
  end

  def caveats
    <<~EOS
      Skill resources: #{opt_libexec}/skills/autoreview
      This formula does not register or replace skills in your agent configuration.
      Reviews require a separately installed and configured supported engine CLI.
      Text reviews need no additional Python packages. For image reviews, run the
      packaged helper with a separately managed Python environment containing Pillow.
    EOS
  end

  test do
    helper = libexec/"skills/autoreview/scripts/autoreview"
    assert_equal "#{version}\n", (libexec/".release-version").read
    assert_path_exists libexec/"skills/autoreview/SKILL.md"
    assert_path_exists libexec/"skills/autoreview/references/engines.md"
    assert_equal "autoreview source-sha256:#{Digest::SHA256.file(helper).hexdigest}\n",
                 shell_output("#{bin}/autoreview --version")
    assert_match "--dry-run", shell_output("#{bin}/autoreview --help")

    # This metadata-only fixture refuses every real reviewer invocation.
    (testpath/"engine").write <<~SH
      #!/bin/sh
      test "$#" -eq 1 && test "$1" = --version || exit 99
      printf '%s\n' 'codex-cli 0.163.0'
    SH
    chmod 0755, testpath/"engine"
    (testpath/"codex-home").mkpath
    ENV["CODEX_HOME"] = (testpath/"codex-home").to_s
    # The helper sanitizes child environments, so bypass Homebrew's internal Git shim.
    ENV["AUTOREVIEW_GIT"] = (formula_opt_bin("git")/"git").to_s
    # Codex preparation requires the OS-private temp root on macOS.
    ENV["TMPDIR"] = shell_output("/usr/bin/getconf DARWIN_USER_TEMP_DIR").strip if OS.mac?
    (testpath/"repo").mkpath
    cd testpath/"repo" do
      system "git", "init", "--quiet"
      (testpath/"repo/example file.txt").write "trusted packaging fixture\n"
      system "git", "add", "example file.txt"
      system "git", "-c", "user.name=Package Test", "-c", "user.email=test@example.test",
             "commit", "--quiet", "--no-gpg-sign", "-m", "Packaging fixture"
      output = shell_output("#{bin}/autoreview --mode commit --commit HEAD --engine codex " \
                            "--codex-bin #{testpath}/engine --dry-run --max-review-passes 1 2>&1")
      assert_match "bundle: constructible", output
      assert_match "prompt: OK", output
      assert_match(/engine check: codex .* OK/, output)
    end
  end
end
