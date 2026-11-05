class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.5.0/wacrawl_0.5.0_darwin_arm64.tar.gz"
      sha256 "598d0ab7f8787c0c2368f03e559be37c5ed2fb89e63eec00e58c6a2b5158fd03"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.5.0/wacrawl_0.5.0_darwin_amd64.tar.gz"
      sha256 "c5d6f27edb28ac7c418a695529d4a66e59820f571fb36a2ebaca39882d550b36"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.5.0/wacrawl_0.5.0_linux_arm64.tar.gz"
      sha256 "a1781ad56106745b9baf21db4a42f0cc059516b8097364687e34e402f4c056cf"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.5.0/wacrawl_0.5.0_linux_amd64.tar.gz"
      sha256 "e8d338872afc030ab6944252fad1fca04be82b39e7f202cb4b67e3a39d057a3f"
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
