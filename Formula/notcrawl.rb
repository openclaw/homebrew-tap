class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.4.0/notcrawl_0.4.0_darwin_arm64.tar.gz"
      sha256 "86c6480d9a4cef4f54e943075d5a0a684d74ca29524e707908c9b023e031a4b1"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.4.0/notcrawl_0.4.0_darwin_amd64.tar.gz"
      sha256 "eeb6fd65006142d2fd1e40d4eac5790f7cdd6e77aa41edf7697c20469f069529"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.4.0/notcrawl_0.4.0_linux_arm64.tar.gz"
      sha256 "2d52a1c46c2df60008f3b37dbc91634befa079efa44f0a88afd197e3e40d9ca1"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.4.0/notcrawl_0.4.0_linux_amd64.tar.gz"
      sha256 "235fff1b661010ed77309d4fea0673ea7b6d5a5980b4f41d7fa0443710478213"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
