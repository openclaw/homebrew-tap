class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.42.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.42.0/gogcli_0.42.0_darwin_arm64.tar.gz"
      sha256 "6a92b35473ed057c55677c2ba7d5af8e154d1bad23fa35e74994bc2f3bce4672"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.42.0/gogcli_0.42.0_darwin_amd64.tar.gz"
      sha256 "f28d7f64fb85d726e4757261a02879f35968ad7096fe00761cd9eda8e9f6d2dd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.42.0/gogcli_0.42.0_linux_arm64.tar.gz"
      sha256 "84ce3002acea162596068c8b25e364aade634d204ae6122b714e686ca783b028"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.42.0/gogcli_0.42.0_linux_amd64.tar.gz"
      sha256 "1967a962a57d689958c408dd0abc784792c3712da9d0a90650bb76ab7e3de388"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
