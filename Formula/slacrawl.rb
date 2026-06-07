class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.0/slacrawl_0.7.0_darwin_arm64.tar.gz"
      sha256 "bd1eaf9eb76ab2513d238b7dddc725c4c3919ccca06de73edc096bb9d2453992"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.0/slacrawl_0.7.0_darwin_amd64.tar.gz"
      sha256 "b3018fc2aa702e3311cd2bc03cecb8e3026cc2a7d87f51d30160010d7b9a8704"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.0/slacrawl_0.7.0_linux_arm64.tar.gz"
      sha256 "41b7b225eaab04e3693d7e24c1a353a527dc729b1db475039c8d422697de532d"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.0/slacrawl_0.7.0_linux_amd64.tar.gz"
      sha256 "70960d311c824d3cfd5ee09a938c95568b1d6bef526200f9e6b3e351fbc83537"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
