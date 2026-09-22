class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.41.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.41.0/gogcli_0.41.0_darwin_arm64.tar.gz"
      sha256 "f1133c7ed9b733b7993a3652b4822fb18cd4a731c9b0b19bdd1049e8288ae5ab"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.41.0/gogcli_0.41.0_darwin_amd64.tar.gz"
      sha256 "d6f879aa6cfc8647f3cad22360418da692959c634c3b2bc397318c7a7e344ae2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.41.0/gogcli_0.41.0_linux_arm64.tar.gz"
      sha256 "a226c1f439f16e946d8d5b73b49da8e65875978adb65d6bc23e7e225e799e966"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.41.0/gogcli_0.41.0_linux_amd64.tar.gz"
      sha256 "bfdb7e67c904098a34a54eb2ae2b1874c41eda7defd7182e5f2c89a2c2ba44c3"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
