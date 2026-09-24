class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.10.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.1/slacrawl_0.10.1_darwin_arm64.tar.gz"
      sha256 "75cbe7f7b1e15b7d804c9fdf4695fe88ae317c0124aadeea8ba675b62e90f1f7"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.1/slacrawl_0.10.1_darwin_amd64.tar.gz"
      sha256 "69d7e5d64ecc00bce40f182fd6b4d32e2624bc374a7ebc55e85d6a9cb5e14dcf"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.1/slacrawl_0.10.1_linux_arm64.tar.gz"
      sha256 "8f7c39e0393ea6d4795e6921a53ad9e6d4ec428c416324999a5a43aecab12e5b"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.1/slacrawl_0.10.1_linux_amd64.tar.gz"
      sha256 "c17e664b2c03cb0f9c68680570ea6095c7dcf22b064ea0ddb3f12033f9034934"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
