class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.5.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.5.1/wacrawl_0.5.1_darwin_arm64.tar.gz"
      sha256 "2243f751b7a0f95b58de2b6a2cf14be2a946b83b07e2201d421b01080a696a3d"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.5.1/wacrawl_0.5.1_darwin_amd64.tar.gz"
      sha256 "eb9ef8589c8ff2fbe6f041a9b5190bb294a6d4163dd523356c3a5d4b4bd933b6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.5.1/wacrawl_0.5.1_linux_arm64.tar.gz"
      sha256 "353197b4eb0e53732c783713e85977d2006d94106095ef0d5bf2964a70d3d18e"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.5.1/wacrawl_0.5.1_linux_amd64.tar.gz"
      sha256 "0ae3e4e3a892f884e4f08ec8cf37ccf934b1fc261a26a3084d98e0420bbc80e6"
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
