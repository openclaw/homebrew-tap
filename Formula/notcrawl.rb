class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.0/notcrawl_0.6.0_darwin_arm64.tar.gz"
      sha256 "c381e109190664aa6febe212fe95eb22c23f82f1b62dff99814d0325120aee86"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.0/notcrawl_0.6.0_darwin_amd64.tar.gz"
      sha256 "0096fe6683cb048133389b59d11c1a8d5406ed51cd42872916cec05688321b19"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.0/notcrawl_0.6.0_linux_arm64.tar.gz"
      sha256 "08650999fa8134365e8548d44b0e329ebbf9d1c4850a280f1eb396a10042e9cc"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.0/notcrawl_0.6.0_linux_amd64.tar.gz"
      sha256 "30b023d96ce5241ca54eaf7f986e9ec499a7127dc38eeda1f69560fd5d69515f"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
