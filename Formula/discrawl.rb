class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.0/discrawl_0.11.0_darwin_arm64.tar.gz"
      sha256 "e7a5267d2ebf243ce8006ac4e7cd6a58cc2cae21dcbfce9e9203a00827a8d85b"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.0/discrawl_0.11.0_darwin_amd64.tar.gz"
      sha256 "808005280f53fd0e8f6dcb1695886388ee85e582c266de5586d6f177eb0b0532"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.0/discrawl_0.11.0_linux_arm64.tar.gz"
      sha256 "70dd7f1c56ae1e8b5569090021c6eac38c14ff4b521188988e20a5808fe86c04"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.0/discrawl_0.11.0_linux_amd64.tar.gz"
      sha256 "8711f2ce05c68dd4dfcc24b3ddda2d15b012f1c715b18b94cfb7d9658eae2315"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
