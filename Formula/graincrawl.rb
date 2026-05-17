class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.1.0/graincrawl_0.1.0_darwin_arm64.tar.gz"
      sha256 "315f7f9997a2eb5d30ec52d27ba601c408b813d30f6af4f076cc52961a924fc0"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.1.0/graincrawl_0.1.0_darwin_amd64.tar.gz"
      sha256 "623af3f715ca0d69a5389a6139e609cc6da709ed4308f8a8a85985a7d969a4ef"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.1.0/graincrawl_0.1.0_linux_arm64.tar.gz"
      sha256 "54cbbbee30a75e114ce056e156aee45e2df8c1c347a53cee4e0c0c614a7105f6"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.1.0/graincrawl_0.1.0_linux_amd64.tar.gz"
      sha256 "5b9e6c834a17e11f62659327259fa1aa1ba339ef5082d590a53e633e43ef0d15"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl version --json")
  end
end
