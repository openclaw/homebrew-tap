class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.4.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.1/wacrawl_0.4.1_darwin_arm64.tar.gz"
      sha256 "3df2c57e8e95ef2c05bb47e43911f192703f20d7b07c59438554d73fe2aaaaaa"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.1/wacrawl_0.4.1_darwin_amd64.tar.gz"
      sha256 "b5dac56ec2b97ac1fd77b1eded96ae1a2c1e4db5636e53f70d97128595f09445"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.1/wacrawl_0.4.1_linux_arm64.tar.gz"
      sha256 "22234795a42fefd15da857eeccf0c775a4a7df14889c75d24beebf3786836b30"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.1/wacrawl_0.4.1_linux_amd64.tar.gz"
      sha256 "74d73c6ea72460d3e796471f1141e447cc06b22c6717ff3bbb0320114c277832"
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
