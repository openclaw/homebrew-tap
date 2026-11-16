class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.4.10"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.10/graincrawl_0.4.10_darwin_arm64.tar.gz"
      sha256 "bfb7cf5ed81d66312348dfb207132f8463f3e6328ee47bb76f795d45a1e3da4a"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.10/graincrawl_0.4.10_darwin_amd64.tar.gz"
      sha256 "20da561858caeebfff0ea7e71ed77d7adb6f0a53df1b6cb211cac17ca0c0fed8"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.10/graincrawl_0.4.10_linux_arm64.tar.gz"
      sha256 "1de0eca598be9971c1f591fe16ac50d9207006787ff4a6795a7707b699148c13"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.10/graincrawl_0.4.10_linux_amd64.tar.gz"
      sha256 "3d4f34b768685692f8864ed5098ce1e01a51ee938b80c554e8f960f2a26a6325"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
