class Peekaboo < Formula
  desc "Lightning-fast macOS screenshots & AI vision analysis"
  homepage "https://github.com/openclaw/Peekaboo"
  url on_arch_conditional(
    arm:   "https://github.com/openclaw/Peekaboo/releases/download/v4.9.8/peekaboo-macos-arm64.tar.gz",
    intel: "https://github.com/openclaw/Peekaboo/releases/download/v4.9.8/peekaboo-macos-x86_64.tar.gz",
  )
  sha256 on_arch_conditional(
    arm:   "5b82b246cd7b257b68d15e136a8234848a8e70a5999cdf5526993fb860685bfe",
    intel: "7792ac5f4cefbd4473c2766d4905ceb486df8da4aa270399cda214b0f4bed877",
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
