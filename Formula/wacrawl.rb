class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.3.11"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.11/wacrawl_0.3.11_darwin_arm64.tar.gz"
      sha256 "9e0b5982c343cf60aa3f036f0191c7b3b0ae84573f44841b7614aef137793cee"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.11/wacrawl_0.3.11_darwin_amd64.tar.gz"
      sha256 "aeecfcf90071f8f541d71b0fee9083267d6527258ed25cbc65d93221fe20fc29"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.11/wacrawl_0.3.11_linux_arm64.tar.gz"
      sha256 "7a6d111631985c40d21a20f24e9a3ab4472c6fbfdf5957c4196f08c081313fb1"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.11/wacrawl_0.3.11_linux_amd64.tar.gz"
      sha256 "e6d756a7445dbe6df7402dd7a08bd47a5ece03a688d499eb015f4c3371253a95"
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
