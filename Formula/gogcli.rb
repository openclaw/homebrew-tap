class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.43.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.43.0/gogcli_0.43.0_darwin_arm64.tar.gz"
      sha256 "e93c2aef60b9a5c14f8f320c9554ed86776920a49afc51b684635aec2f5ca050"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.43.0/gogcli_0.43.0_darwin_amd64.tar.gz"
      sha256 "b736ef888ab8c56bfc2d2ad83e5ab73d5aea983672b9f69052c8713e9daddd5c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.43.0/gogcli_0.43.0_linux_arm64.tar.gz"
      sha256 "f66e3c9ab7664b7633d57d2d5303e0db75deb4045e1b32c3493c0d8ba68a70f7"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.43.0/gogcli_0.43.0_linux_amd64.tar.gz"
      sha256 "a16d4b8b917e36b96b09b30ecb7a5049d06ff1e88b856a101eec12b86b33fe05"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
