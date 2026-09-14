class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.2/notcrawl_0.6.2_darwin_arm64.tar.gz"
      sha256 "33acf8378adc1d5078f7bd601340713bc9dc0af53cb2472948b114c02adff4b0"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.2/notcrawl_0.6.2_darwin_amd64.tar.gz"
      sha256 "c5ecd1f53f2b251190833deb721a76bbdbfb8d325bd13e52d8efcc1772636ca6"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.2/notcrawl_0.6.2_linux_arm64.tar.gz"
      sha256 "4327be1999ef992d4371bda2c0fe847d1eeb9b001e9c1fecc4b1bff2e92fc0f8"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.2/notcrawl_0.6.2_linux_amd64.tar.gz"
      sha256 "ead35bfc22439484204d65e9e1ddb6aaf70b49587a5da95062f3c23daa5521e0"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
