class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.34.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v#{version}/gogcli_#{version}_darwin_arm64.tar.gz"
      sha256 "8fcc471ec4b4efaee775ac2963da966bd18d95db904274b57bcbbece850b80e4"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v#{version}/gogcli_#{version}_darwin_amd64.tar.gz"
      sha256 "999069dc941e4f411fd7aab60759e2d44b70757640ef5f76658930d562464f1b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v#{version}/gogcli_#{version}_linux_arm64.tar.gz"
      sha256 "ec4e67c64aabf3107293905d4e6e2acb35c8b88cfb0e2af6cd52c27b34ccd436"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v#{version}/gogcli_#{version}_linux_amd64.tar.gz"
      sha256 "7485f4fd8ce9f7ec62abfbeb4df19d7a11ad1d4e9ec6ff2e39aca973144c6fb8"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
