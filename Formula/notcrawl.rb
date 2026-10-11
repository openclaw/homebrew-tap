class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.5/notcrawl_0.6.5_darwin_arm64.tar.gz"
      sha256 "42cd4d6a6e5805569a681748426b5d1a9aa386847299c6227168378f043f5ea6"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.5/notcrawl_0.6.5_darwin_amd64.tar.gz"
      sha256 "2cbd22623be35e32e2b03c413abb009aaa9b33c60dac432011d982c82e3d26fa"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.5/notcrawl_0.6.5_linux_arm64.tar.gz"
      sha256 "bec57c5f9c9d79014774c87f6e153266dcc6476073b094481c489b1ae0f79d58"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.5/notcrawl_0.6.5_linux_amd64.tar.gz"
      sha256 "074a668ed642f07eb95384b2a6e9015639146824ca94865129fbf72752a65665"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
