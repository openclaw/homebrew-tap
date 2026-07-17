class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  version "0.5.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.3/notcrawl_0.5.3_darwin_arm64.tar.gz"
      sha256 "54ab34ffe4172333739c601948b9022021fc81a2126744323eecde5687ee7d9b"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.3/notcrawl_0.5.3_darwin_amd64.tar.gz"
      sha256 "db03d20cdba9d0eba7e788313abf4c4bf47de0d96de77087a08898879c4b09db"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.3/notcrawl_0.5.3_linux_arm64.tar.gz"
      sha256 "e1918fa2a5ccca2c6642ad4c261c3220d833fd41ea6d7439e44e26e1e57eefbd"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.3/notcrawl_0.5.3_linux_amd64.tar.gz"
      sha256 "d8568702a299aa77b9cf28bb09bcd637a7e1b70c23133a5868012f3b42db1a0f"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
