class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.4.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.3/wacrawl_0.4.3_darwin_arm64.tar.gz"
      sha256 "b48cc3aa023a6d3f9450540fbf8e6b84c0caab2d70e60be8230bca18aafe22f5"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.3/wacrawl_0.4.3_darwin_amd64.tar.gz"
      sha256 "a9ce2653f4951cdb0c1952d870cfa7b371e8f49597430a9ddbfe2758537e7034"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.3/wacrawl_0.4.3_linux_arm64.tar.gz"
      sha256 "2e92da5a36676388e3f2118a13b9e5062d2458804359b9658504d67f34984842"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.3/wacrawl_0.4.3_linux_amd64.tar.gz"
      sha256 "4d848b7c2fe80bee50970b400f2e56ce20db9756fc87f155ae3aa0defb67366c"
    end
  end

  def install
    bin.install "wacrawl"
  end

  def caveats
    <<~EOS
      wacrawl reads WhatsApp Desktop data from:
        ~/Library/Group Containers/group.net.whatsapp.WhatsApp.shared

      It writes its archive to:
        ~/.wacrawl/wacrawl.db

      Quick start:
        wacrawl doctor
        wacrawl import
        wacrawl status
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wacrawl --version")
  end
end
