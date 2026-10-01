class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.6/discrawl_0.15.6_darwin_arm64.tar.gz"
      sha256 "8c2679c5eab5385832a142091ecdd44f0fc05757c76d09b66a1ec67d7713ebed"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.6/discrawl_0.15.6_darwin_amd64.tar.gz"
      sha256 "a59ca6dd5bfa3426a007b9a8d317e4e262638d06e1a1ccaaa9c23cc2b5e1d268"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.6/discrawl_0.15.6_linux_arm64.tar.gz"
      sha256 "bb80618e7b260665bc589fc90194d1a9ec7a99b4f4e6b37d2c9cb0b58b7a4964"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.6/discrawl_0.15.6_linux_amd64.tar.gz"
      sha256 "fac6f74f50c2deb6bd2a86e257a686b65cc424cf589fba314cb17f1e19aa544d"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
