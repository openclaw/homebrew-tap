class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.10.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.0/slacrawl_0.10.0_darwin_arm64.tar.gz"
      sha256 "3ec0ef43435da79d77ab54651a8deed6d74c99e659359f7353f3afef2b72a504"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.0/slacrawl_0.10.0_darwin_amd64.tar.gz"
      sha256 "534d1c1491370dac406a09f8ef4abc0f8c65c82e3f92e37248ad1da3722fb4ee"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.0/slacrawl_0.10.0_linux_arm64.tar.gz"
      sha256 "56f362b4904f1e84c834a4ee788f2c701373ea66ed39bd03b44f4290dfc0eb71"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.0/slacrawl_0.10.0_linux_amd64.tar.gz"
      sha256 "df31febd8a53b9c7334830bb3e32ede5209d0e2faf81c305e6473738566d9c31"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
