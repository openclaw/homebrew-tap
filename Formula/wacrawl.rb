class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v#{version}/wacrawl_#{version}_darwin_arm64.tar.gz"
      sha256 "e982afcf7329bb825e0543319b257cd4ecc9f9e2e43423dc220068387fe7c596"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v#{version}/wacrawl_#{version}_darwin_amd64.tar.gz"
      sha256 "43f09307daa18e337444ad68c83e67c87f5f5c10b64e242b4a57ee90908dacb5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v#{version}/wacrawl_#{version}_linux_arm64.tar.gz"
      sha256 "960eccbd47e60da3dd49a9e98380fb23b76e4262f03ea51de0a1db3f3ca3c5d3"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v#{version}/wacrawl_#{version}_linux_amd64.tar.gz"
      sha256 "49ffa9bfc6efa96afadfaf31aeabe40ca19ec77e122795f47df33d1312d30831"
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
