class Peekaboo < Formula
  desc "Lightning-fast macOS screenshots & AI vision analysis"
  homepage "https://github.com/openclaw/Peekaboo"
  url on_arch_conditional(
    arm:   "https://github.com/openclaw/Peekaboo/releases/download/v4.9.10/peekaboo-macos-arm64.tar.gz",
    intel: "https://github.com/openclaw/Peekaboo/releases/download/v4.9.10/peekaboo-macos-x86_64.tar.gz",
  )
  sha256 on_arch_conditional(
    arm:   "ebd37b07edc9c6f7f526086ec762ce9f50efd508db713e1c0bf2b36f69714037",
    intel: "284f1cc7528c39971f95f93e53a287d6663a3cfcbfd0f2d7a4da34f8a23187ef",
  )
  license "MIT"

  # macOS Sequoia (15.0) or later required
  depends_on macos: :sequoia

  def install
    bin.install "peekaboo", *Dir["libswiftCompatibility*.dylib"]
  end

  def caveats
    <<~EOS
      Peekaboo requires Screen Recording permission to capture screenshots.

      To grant permission:
      1. Open System Settings > Privacy & Security > Screen & System Audio Recording
      2. Enable access for your Terminal application

      For AI analysis features, configure your AI providers:
        export PEEKABOO_AI_PROVIDERS="openai/gpt-5.1,anthropic/claude-sonnet-4.5"
        export OPENAI_API_KEY="your-api-key"

      Or create a config file:
        peekaboo config init
    EOS
  end

  test do
    assert_match "Peekaboo", shell_output("#{bin}/peekaboo --version")
    assert_match(/\AUsage\n\s+peekaboo\b/, shell_output("#{bin}/peekaboo --help"))
  end
end
