class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.4.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.4/graincrawl_0.4.4_darwin_arm64.tar.gz"
      sha256 "ef9f38ea449e91f0ef35edf157288c941ea4a036cc8edc0fb9f073ba1d676362"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.4/graincrawl_0.4.4_darwin_amd64.tar.gz"
      sha256 "db017772afc6ec7db0d24bbca8ba15aad8307f2b7d41a5f5b6060e089646c57e"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.4/graincrawl_0.4.4_linux_arm64.tar.gz"
      sha256 "831bec82f5ae0fb27effa31b037fa83d95ec956cb46ea4ac303969f01dc0c468"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.4/graincrawl_0.4.4_linux_amd64.tar.gz"
      sha256 "e636fda2b320696ad129a7ddcb08470aa51325e18ac5fddc7c4ad322b0edd6f9"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
