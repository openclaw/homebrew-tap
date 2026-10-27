class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.4.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.8/graincrawl_0.4.8_darwin_arm64.tar.gz"
      sha256 "cf2680c7c7f56f206df1f922d974927e516035ff08d296379cfe21679523b4f0"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.8/graincrawl_0.4.8_darwin_amd64.tar.gz"
      sha256 "8580f8ab4fa03819620e8789e4dfbd67df79e43e4e960f7c0bf2799f9550d5ad"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.8/graincrawl_0.4.8_linux_arm64.tar.gz"
      sha256 "71378fc2bda1c9b276b395a3562df95ef810f5c6ed68bb8654b45bcb0dfa2011"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.8/graincrawl_0.4.8_linux_amd64.tar.gz"
      sha256 "aca7c82612367c6563d52670313e7b8563f5489fa0a46fc6509d8f0f8498fa26"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
