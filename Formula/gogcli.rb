class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.48.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.48.1/gogcli_0.48.1_darwin_arm64.tar.gz"
      sha256 "efb56f2400fcf6a7f25ae38a1e165fb4f9f5fd7f7b18e76b4c0b82c1e35b802f"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.48.1/gogcli_0.48.1_darwin_amd64.tar.gz"
      sha256 "c8d8a0f0ecc93b85c47e8be792bc9ac1a68de3a7cfabbc26e6e3ac3baa882635"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.48.1/gogcli_0.48.1_linux_arm64.tar.gz"
      sha256 "c091fa2014dc3d5608acef4d09fb3bb4a3eb71e4cff898b5eaddd9703599e45c"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.48.1/gogcli_0.48.1_linux_amd64.tar.gz"
      sha256 "dcd956e09d1222a07c1304d836f8acd55266b2fa241ef466580ced6a02453d72"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
