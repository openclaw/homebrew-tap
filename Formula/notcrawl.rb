class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.13/notcrawl_0.6.13_darwin_arm64.tar.gz"
      sha256 "e58355abcfa94f3d27bcf083ed5573ae3444b2987c27b0b15b6f88b2ac969489"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.13/notcrawl_0.6.13_darwin_amd64.tar.gz"
      sha256 "e0f7dcc9ac7448117a51205c7391108290ddb2c844b9519d4f9b66c24965fc6d"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.13/notcrawl_0.6.13_linux_arm64.tar.gz"
      sha256 "085e560cb49b8f4896ee290de44dda7f5edc763f8f911ea5f3007af5afdb83fc"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.13/notcrawl_0.6.13_linux_amd64.tar.gz"
      sha256 "1933d3f8887065b60772cb6525d1c2437db47b78063285aed52f060755ed1b86"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
