class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.14.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.14.0/discrawl_0.14.0_darwin_arm64.tar.gz"
      sha256 "0988d5b7ec06f9aaf6beff482c901c4d6a2e447e4b7fd53d22c42357b2d358b3"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.14.0/discrawl_0.14.0_darwin_amd64.tar.gz"
      sha256 "a677ee5407063397085c4ff7260348f726cdbd974f298f5a1c8c2fdf5079267a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.14.0/discrawl_0.14.0_linux_arm64.tar.gz"
      sha256 "c6d2735009af3307d99489f3831964c630784ec3b49926bde6923e3989f7a91e"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.14.0/discrawl_0.14.0_linux_amd64.tar.gz"
      sha256 "0f80197b0d8b9478ae87f98da08d30d52dbb0766aea091067c8eee0ffafef40d"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
