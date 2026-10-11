class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.44.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.44.0/gogcli_0.44.0_darwin_arm64.tar.gz"
      sha256 "e546def2a08c80abbef2138a7f02e63f6ba91dcf04cc94873d2da113b8d116c2"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.44.0/gogcli_0.44.0_darwin_amd64.tar.gz"
      sha256 "7ba54f53945344d4e5f0279797aea64e19024baf6fc454538621415261d2b5f0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.44.0/gogcli_0.44.0_linux_arm64.tar.gz"
      sha256 "0346149cac6630996c69911ac7366c3c1a36d8835b23e985e90c3f8d25c7ab65"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.44.0/gogcli_0.44.0_linux_amd64.tar.gz"
      sha256 "9e40b7e51be9162e5ab92d255376257e4d594e9e64dc360fffccd85ba4e1c0c0"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
