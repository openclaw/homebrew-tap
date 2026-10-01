class Wacrawl < Formula
  desc "Read-only WhatsApp Desktop archive CLI"
  homepage "https://github.com/openclaw/wacrawl"
  version "0.4.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.2/wacrawl_0.4.2_darwin_arm64.tar.gz"
      sha256 "d972f2772e42b1cef4f4d597b37a8a0a1ccde47014dcbabd00a18d81ea4a048f"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.2/wacrawl_0.4.2_darwin_amd64.tar.gz"
      sha256 "747f9124e8e0dd3a2ef7854015fe9d7acea0a4328428ba561002b6cdfa4f2ecb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.2/wacrawl_0.4.2_linux_arm64.tar.gz"
      sha256 "d99061647ad16fc7da84660bb754593159ea91f1799a296fe799f6fa583b7e2c"
    else
      url "https://github.com/openclaw/wacrawl/releases/download/v0.4.2/wacrawl_0.4.2_linux_amd64.tar.gz"
      sha256 "fc82ee776afda99f8c154563e4b746a326c309088480affbe65bda053d872fba"
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
