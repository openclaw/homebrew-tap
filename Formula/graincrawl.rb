class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.0/graincrawl_0.3.0_darwin_arm64.tar.gz"
      sha256 "bc431a2227641156354365c32b1934d573a5cb9e4e630545e0cf9663b6d45fc2"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.0/graincrawl_0.3.0_darwin_amd64.tar.gz"
      sha256 "7ad1387328717ce91e99598aa5ba6ad2a108bf8ed9ce2a4cd60e81150a2c5627"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.0/graincrawl_0.3.0_linux_arm64.tar.gz"
      sha256 "4c5a2725e5c1b153a4fcc2a03a6e0f303cbd2e46627fad3b0818e9fb6e30d419"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.0/graincrawl_0.3.0_linux_amd64.tar.gz"
      sha256 "88631b11168139bce56c7981affe21b0462b48ac926e916c2d3752943e25f3b5"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl version --json")
  end
end
