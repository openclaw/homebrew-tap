class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.4/notcrawl_0.6.4_darwin_arm64.tar.gz"
      sha256 "85647cf8631679982629ca1d9ff2829668d6d98286e7e96fd97b64a22ae5f3e0"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.4/notcrawl_0.6.4_darwin_amd64.tar.gz"
      sha256 "5abaad1d0d2b05a8949df8c0381e8968c9aa6ce489bcdf55e3b2093a8788ae39"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.4/notcrawl_0.6.4_linux_arm64.tar.gz"
      sha256 "a5bc535601df7f1e17c215a9160717c803de0f441344687423f8436c1966e8f6"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.4/notcrawl_0.6.4_linux_amd64.tar.gz"
      sha256 "99c52b47d3120801c249eba8636197f5ba05f606208ea85e53c7399134a59135"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
