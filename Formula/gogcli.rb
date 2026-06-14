class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.26.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.26.0/gogcli_0.26.0_darwin_arm64.tar.gz"
      sha256 "68ca0a00b732e2ff77af47161b53237f4918c1482d0ba5e4346c8494dc857667"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.26.0/gogcli_0.26.0_darwin_amd64.tar.gz"
      sha256 "d4162ec16590e22a7eb1f5e1e7754b591fe15af1d8ccfaea1f7f311f666a85c5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.26.0/gogcli_0.26.0_linux_arm64.tar.gz"
      sha256 "9f10f249aebb2f2d213bbb7f4cdb093f224484c05294911e8dba870c28211f22"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.26.0/gogcli_0.26.0_linux_amd64.tar.gz"
      sha256 "a767e176c9aa475f52e73e6fdde74f5ca168f05a9f325117cfa993a12af7d753"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
