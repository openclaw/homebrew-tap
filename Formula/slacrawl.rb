class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.8.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.8.7/slacrawl_0.8.7_darwin_arm64.tar.gz"
      sha256 "7dcaeacde58974d24255e3cb76ebcfa91ccdb3872571ae69eae82abfe3e14d66"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.8.7/slacrawl_0.8.7_darwin_amd64.tar.gz"
      sha256 "378c0b3c8c157adead024b0e7a178f277c226e8ff7aca8b260a9877a5adbb665"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.8.7/slacrawl_0.8.7_linux_arm64.tar.gz"
      sha256 "7ae75a47d1d1195e702185c74cc645438bef0a7242545e0fc82f04544dfb5d14"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.8.7/slacrawl_0.8.7_linux_amd64.tar.gz"
      sha256 "c8efe9a7298c914f89c45deae590e13dea954467d4d90e185dacd0961a5ab5a8"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
