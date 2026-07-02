class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.4/discrawl_0.11.4_darwin_arm64.tar.gz"
      sha256 "2aa2d13dac75d0cccabaab8ba8ac83314310b6e39a27ee590f4933c498798230"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.4/discrawl_0.11.4_darwin_amd64.tar.gz"
      sha256 "01ab8d1edcd5945156724bdb66c7a728f30a48766e0ef2dafe0b1f2b04217eb4"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.4/discrawl_0.11.4_linux_arm64.tar.gz"
      sha256 "a2ff8f9ddb38042741149db2c131d336637fecf43d3d3cea06bf93293b868400"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.4/discrawl_0.11.4_linux_amd64.tar.gz"
      sha256 "2540a7578fb27c443263c3c8c129e7ff37ae68b77d8817b7d8cf4231e6e80bf7"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
