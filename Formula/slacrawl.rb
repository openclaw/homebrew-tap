class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.12.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.12.0/slacrawl_0.12.0_darwin_arm64.tar.gz"
      sha256 "658dd616eeb391fd1800fa24abaac6e02844163bcafd089220123a704177a891"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.12.0/slacrawl_0.12.0_darwin_amd64.tar.gz"
      sha256 "66b7747ed4c51e168f33ddcad953ff0cf0ef387f64edad821eca3b5fc955a60a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.12.0/slacrawl_0.12.0_linux_arm64.tar.gz"
      sha256 "0fb1fa51438c35e5e1a5a64458122e06202f8bdc716b6db4cb0f9d9d48e2f295"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.12.0/slacrawl_0.12.0_linux_amd64.tar.gz"
      sha256 "0a8f75d3a563ba4c0387d05f4ebd26cfb5d9c82f22f78968f5d69f0b4a28ecc1"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
