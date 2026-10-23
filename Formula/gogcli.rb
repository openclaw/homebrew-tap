class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.47.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.47.0/gogcli_0.47.0_darwin_arm64.tar.gz"
      sha256 "ee0826a457f3d440e5272e4135a2bfd98a6c79e8734f5789055f6f09523120af"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.47.0/gogcli_0.47.0_darwin_amd64.tar.gz"
      sha256 "2670eb51d116b217f879889b16288867d1894d7128b8d3e5c3087b81424ea28d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.47.0/gogcli_0.47.0_linux_arm64.tar.gz"
      sha256 "90d236ab91c6dae7139bfe0508eab94a8b4323238b62fa29e6cf479a352576f2"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.47.0/gogcli_0.47.0_linux_amd64.tar.gz"
      sha256 "c3ed94efca90c754cdda300e3c7f8cc2f3d7df86d3fdc5d11f996c7518a09c24"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
