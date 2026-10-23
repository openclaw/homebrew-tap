class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.9/notcrawl_0.6.9_darwin_arm64.tar.gz"
      sha256 "bc8efb3d0483b213743c59e746551a1abb7c198d6895b706fe8922d087f51f3f"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.9/notcrawl_0.6.9_darwin_amd64.tar.gz"
      sha256 "275238091e0557b52f2d12601321174d4f25987f3be2a9f629a734d171d22602"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.9/notcrawl_0.6.9_linux_arm64.tar.gz"
      sha256 "ff8d593c19a5f6940fd09180fc00a26a942437240ace89264397c0357ac235c8"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.9/notcrawl_0.6.9_linux_amd64.tar.gz"
      sha256 "5c5ef3fc8dedba539f9abe3a6709cd010f65e33fdf854da0fe96a8b5e893cc96"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
