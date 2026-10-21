class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.46.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.46.0/gogcli_0.46.0_darwin_arm64.tar.gz"
      sha256 "7a71338870665a0ff7ff4f5d76f9e1cc1f6e01c91ea2d40781ef5d3eb587a42c"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.46.0/gogcli_0.46.0_darwin_amd64.tar.gz"
      sha256 "963069b3284f26411bde794ca4067ae7b80e523ff22108ffacc0d71a4ae6a074"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.46.0/gogcli_0.46.0_linux_arm64.tar.gz"
      sha256 "9ae69d117cef895aa1c50b5859d7d3def45c5580886b25dc1c7f3cfe128ed0dd"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.46.0/gogcli_0.46.0_linux_amd64.tar.gz"
      sha256 "d53cf89f0c2a2338211212e380b3efcacadd4e27e500cb8e7ed2cd82a739da2e"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
