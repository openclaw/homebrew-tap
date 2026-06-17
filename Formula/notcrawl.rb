class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  version "0.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.0/notcrawl_0.5.0_darwin_arm64.tar.gz"
      sha256 "9beda714c38a0ace3bf2cc10b95fdea526668604073c02defb35142367ff0041"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.0/notcrawl_0.5.0_darwin_amd64.tar.gz"
      sha256 "c6b028ed5238efcb167f18569622a42a130d5402e5924f4e844c1e3fe0c40ae2"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.0/notcrawl_0.5.0_linux_arm64.tar.gz"
      sha256 "4909f54a06288ddef38c663d85e4e240d6eb25d8af672de9bf1c7a059270fcf9"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.0/notcrawl_0.5.0_linux_amd64.tar.gz"
      sha256 "739451589ddeca37e9ae8c0696be0be5a5fcf5cdfba19eca4240d54e4c183c3a"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
