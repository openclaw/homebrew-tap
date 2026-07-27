class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.10"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.10/slacrawl_0.7.10_darwin_arm64.tar.gz"
      sha256 "5ecf5614e0a94eb7fcd960e5b7026bc4df3722013d5031764d918575fc65e1f6"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.10/slacrawl_0.7.10_darwin_amd64.tar.gz"
      sha256 "f6ccfea96df62627fda5e233888eeea3a90f9e03c601f9e38a788dc6ac472421"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.10/slacrawl_0.7.10_linux_arm64.tar.gz"
      sha256 "4bb12f5f8644903fd7b9df8f4c333c1ba166f4ec7895590725e7536c6f94321b"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.10/slacrawl_0.7.10_linux_amd64.tar.gz"
      sha256 "e6bbfd1fd343282dfc33427d6cf0df7c0f89f50c7e28400b34374825a8b4d93f"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
