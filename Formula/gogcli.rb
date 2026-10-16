class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.45.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.45.0/gogcli_0.45.0_darwin_arm64.tar.gz"
      sha256 "10dafd2403f5985aea44d945998e135e477a6b6ef20939e0a9fcdab152d89b8a"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.45.0/gogcli_0.45.0_darwin_amd64.tar.gz"
      sha256 "53510415394784b8d788fa26ed9fd7b58348181865e9e419889530f9c1b150d2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.45.0/gogcli_0.45.0_linux_arm64.tar.gz"
      sha256 "6eb4734b3a14a4c96f63c9747d06495265f3a4518a17dec0a4a4a710c76bcb2b"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.45.0/gogcli_0.45.0_linux_amd64.tar.gz"
      sha256 "aa39f6149d6a1482cd71b7baf21b9c7a4bf87fe9e9118439c4e97026063e915f"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
