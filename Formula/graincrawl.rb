class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.4.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.9/graincrawl_0.4.9_darwin_arm64.tar.gz"
      sha256 "9687497d73be4cc13954b64faac34796a752fad0f76613e3575d932f5b1d62ab"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.9/graincrawl_0.4.9_darwin_amd64.tar.gz"
      sha256 "4524eca9a933080de0e3819d25b37faccb1e947ca6deba77aedd3824d2248df1"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.9/graincrawl_0.4.9_linux_arm64.tar.gz"
      sha256 "d2186c0f09a0957bcb7509821d98c40fa0b2a86be9772f8765be6c83b758c9a0"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.9/graincrawl_0.4.9_linux_amd64.tar.gz"
      sha256 "e6789f126e22ad4845f4cc81f6c598c127882e948e6be30263cbe27454c27248"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
