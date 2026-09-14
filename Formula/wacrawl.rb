class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.3.13"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.13/wacrawl_0.3.13_darwin_arm64.tar.gz"
      sha256 "1c5d07ed128795a6181bc7f756f7d76ec68aa2128f61ea690baa1a6b1c2aa796"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.13/wacrawl_0.3.13_darwin_amd64.tar.gz"
      sha256 "10f755814fbe6aeccd42acdcb1cce1cf84768aa4bce4e5d1b27e8216a4407e34"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.13/wacrawl_0.3.13_linux_arm64.tar.gz"
      sha256 "1837a2eb9b8bc2680b056bf9d3d7ec706e297b7c446245f04a0ed14c1b7494ce"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.13/wacrawl_0.3.13_linux_amd64.tar.gz"
      sha256 "d98eaf314a1f8137343641b3d5defaffe0ece80996262c48ea9f7fbc851d00a3"
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
