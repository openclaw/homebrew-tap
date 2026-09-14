class Peekaboo < Formula
  desc "Lightning-fast macOS screenshots & AI vision analysis"
  homepage "https://github.com/openclaw/Peekaboo"
  url "https://github.com/openclaw/Peekaboo/releases/download/v4.4.0/peekaboo-macos-universal.tar.gz"
  sha256 "6260d3560dc05b8df6621ffac5544ff987291105842ffeb652ecf018ec725d45"
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
