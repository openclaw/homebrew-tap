class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.3.12"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.12/wacrawl_0.3.12_darwin_arm64.tar.gz"
      sha256 "1a64a03dd51546bcad705e4babd5b865cc4665dac0ced28ff8683667b8e34e88"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.12/wacrawl_0.3.12_darwin_amd64.tar.gz"
      sha256 "6b9845d45b4d146a7f3bf4e9e4d93c3047656c482298e8ce98f0d018e660e2fe"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.12/wacrawl_0.3.12_linux_arm64.tar.gz"
      sha256 "717c792649ccab277fa6fd6864aa5d3e67263baad7563f94b2fe3b303a537fd2"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.3.12/wacrawl_0.3.12_linux_amd64.tar.gz"
      sha256 "e88ad7f0a8797da378deb551c919d42c7efcc9d023d56415778893d6f3166bca"
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
