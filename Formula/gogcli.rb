class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.32.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.32.0/gogcli_0.32.0_darwin_arm64.tar.gz"
      sha256 "72c7c928c88ba9162613e6c15593098f29e1195a50f27dd87949fb377cf245a5"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.32.0/gogcli_0.32.0_darwin_amd64.tar.gz"
      sha256 "3bfdaab971ab9b28e3274336a16eafb03b2bea57bf6f48af447744856c79a849"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.32.0/gogcli_0.32.0_linux_arm64.tar.gz"
      sha256 "d1eefeda5547b9f1dd6c804d4573e2873cfd62a38f92d25057e18f0af8ce7e93"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.32.0/gogcli_0.32.0_linux_amd64.tar.gz"
      sha256 "342b3084a85eeb521e58d2e1904f5d4abfceec1505cea7b56557f577f6510ea4"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
