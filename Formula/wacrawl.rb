class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.0/wacrawl_0.4.0_darwin_arm64.tar.gz"
      sha256 "ce0c1131bb85edb19ab7069213b4496db88bf523091b427f21329ce453cd7b01"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.0/wacrawl_0.4.0_darwin_amd64.tar.gz"
      sha256 "f4b3d625096a04d910f212ea5286c456e4ac873e001decac143d8dd934068e24"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.0/wacrawl_0.4.0_linux_arm64.tar.gz"
      sha256 "e6c213ec488f785bb0ff31633147164ca956a283680b8604c5c34b15dbf803e7"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.0/wacrawl_0.4.0_linux_amd64.tar.gz"
      sha256 "a10367456b85e9414b23d74ab1c3ff89cebd2b4d29727f4616c70a7c0bce33f8"
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
