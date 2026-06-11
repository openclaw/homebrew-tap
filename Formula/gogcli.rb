class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.24.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.24.0/gogcli_0.24.0_darwin_arm64.tar.gz"
      sha256 "2c10fd54fbcb9b9926551a89e87f680663ab8025f9f6fc6118d19d4e5be3752a"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.24.0/gogcli_0.24.0_darwin_amd64.tar.gz"
      sha256 "407bee606a86fbc5962afd5385741ba7d0adfccb7949b2cf2c4250f657d5bb22"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.24.0/gogcli_0.24.0_linux_arm64.tar.gz"
      sha256 "f390cd71d77181c30b448c993cdf052567299e816e1161ae5cd30c3c7d4eb6b2"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.24.0/gogcli_0.24.0_linux_amd64.tar.gz"
      sha256 "4993d1264ae43a142e998e5c696662a658f13c044c7210212f4400beeb38e885"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
