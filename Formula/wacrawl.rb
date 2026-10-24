class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.4.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.4/wacrawl_0.4.4_darwin_arm64.tar.gz"
      sha256 "eb75157c90df684b821e3fca49c30871f81f8ce91f972c05bfd41a058f0a2713"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.4/wacrawl_0.4.4_darwin_amd64.tar.gz"
      sha256 "7bd653f67916a5cf31074276c96e270260a6700b89344a5054f295169a3629f2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.4/wacrawl_0.4.4_linux_arm64.tar.gz"
      sha256 "41f8ec3a918a29bd2d2801d281002d85246d95e6000d1fc3e8a7ace748956aa2"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.4/wacrawl_0.4.4_linux_amd64.tar.gz"
      sha256 "2fac25ebbc6c5ee9f54a1df4aae91658a01318d95e47bd262be57adb6c8b70cd"
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
