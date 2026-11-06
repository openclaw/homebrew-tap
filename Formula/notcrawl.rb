class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.12/notcrawl_0.6.12_darwin_arm64.tar.gz"
      sha256 "8a262e4badc0796cfef989ab5a57d34c182dd0139660505df14fe77f3bd056a1"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.12/notcrawl_0.6.12_darwin_amd64.tar.gz"
      sha256 "522d58a0332f72ce138458b64d3c31076c53f9ac43564faefd29071703ac3f34"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.12/notcrawl_0.6.12_linux_arm64.tar.gz"
      sha256 "f4ffb0368bf47f26da2de67f35313b9e54abbe1f50bc54a08894ee09da4f624f"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.12/notcrawl_0.6.12_linux_amd64.tar.gz"
      sha256 "421674229aa7d1f320d5aa3de2a6138c3cdfef3cd78c59fcbbe70f683b9b327a"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
