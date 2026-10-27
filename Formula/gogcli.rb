class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.47.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.47.1/gogcli_0.47.1_darwin_arm64.tar.gz"
      sha256 "40078e4a5d55ebf16bdbc99d4f5c0e3f0d5e8c862d536417ae4eae3c4008571a"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.47.1/gogcli_0.47.1_darwin_amd64.tar.gz"
      sha256 "bf7144a9d6f6ecebbabd2028f121fabcec0f248dd69393991adda6f34e2aaf9e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.47.1/gogcli_0.47.1_linux_arm64.tar.gz"
      sha256 "c677ac6abf5e187e987a87fe1b588f454b002a7d7019de81b9e8db02e9e902b6"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.47.1/gogcli_0.47.1_linux_amd64.tar.gz"
      sha256 "279bc3a03c1919d774e268ef229949f45b753a0e21257f9fb315b05be7a40ea9"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
