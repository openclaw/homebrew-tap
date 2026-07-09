class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.3.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.2/graincrawl_0.3.2_darwin_arm64.tar.gz"
      sha256 "935afb2024f5447680d8c8cb315ac0c8ae845538cf15b093bd5fba42bbe843b8"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.2/graincrawl_0.3.2_darwin_amd64.tar.gz"
      sha256 "2af3268d5247d687a09a2882463e0b910abb01f9ee8981849d77b4789d4342bd"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.2/graincrawl_0.3.2_linux_arm64.tar.gz"
      sha256 "6177a058cc61df60fda3afccb942f5dfb2d38c1fdc6a04d973a2cf2f8a35dcc1"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.2/graincrawl_0.3.2_linux_amd64.tar.gz"
      sha256 "4da3ad511afbff5a61ced56b14c5208a44058e6895aaf6d070b45863a10d8d8f"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
