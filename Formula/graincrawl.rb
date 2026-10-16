class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.4.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.6/graincrawl_0.4.6_darwin_arm64.tar.gz"
      sha256 "695dee1965ac870add625c886454a6fdcf07c84290f2285fe15bc513e94c7349"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.6/graincrawl_0.4.6_darwin_amd64.tar.gz"
      sha256 "b9dc33332665fc1c3fcb77b4bad9b422d7f271bc08e53df977b3f9065c08d9f4"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.6/graincrawl_0.4.6_linux_arm64.tar.gz"
      sha256 "23307d239f7dc42374ca8f1d08642d064376a58e63e4ec7427bf610c1ca05367"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.6/graincrawl_0.4.6_linux_amd64.tar.gz"
      sha256 "f478cadd941cd179c887e544a040f57ef3866863a70a3be10008090dea30cb0d"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
