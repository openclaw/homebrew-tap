class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.19.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.19.0/gogcli_0.19.0_darwin_arm64.tar.gz"
      sha256 "aa5e94915ab015707894cc7a44114bc9398c5aa98be199dfe39cf6ea0ee9ebe5"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.19.0/gogcli_0.19.0_darwin_amd64.tar.gz"
      sha256 "db2e99f818d320b654b05a34c3b6a8cadd01235bd9da1b4cb6d01608734d4721"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.19.0/gogcli_0.19.0_linux_arm64.tar.gz"
      sha256 "b0dfcd8b8dc6d38ad3901444273b3e862ee9fb49b9e47b232ca0e9252892222d"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.19.0/gogcli_0.19.0_linux_amd64.tar.gz"
      sha256 "89cd76b60d07f64b931c5a964aba47dc408212aaf6ff558c1a6e8dc1dc0fd1c9"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
