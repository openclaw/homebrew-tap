class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.6/notcrawl_0.6.6_darwin_arm64.tar.gz"
      sha256 "fe36c7bb23fe0aeab5bd8374e1ea688e91df9266e760600aa2ec3e1d162ea772"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.6/notcrawl_0.6.6_darwin_amd64.tar.gz"
      sha256 "c8396a38c8d9aed14ba357e3c131c77e8a7473bbbb99b0d7e7a0b6959e95560a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.6/notcrawl_0.6.6_linux_arm64.tar.gz"
      sha256 "df1f04b2b98834671b962df5e00bc3f45d37777bf1fc824f1aa94b642d5c076c"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.6/notcrawl_0.6.6_linux_amd64.tar.gz"
      sha256 "c0006f5e71d8fce4c4a85c7d201e7d437afe8916f25b5884c2228404f1505ee4"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
