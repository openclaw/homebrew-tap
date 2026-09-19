class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.3/discrawl_0.15.3_darwin_arm64.tar.gz"
      sha256 "517f3e3f4fdc75ec8ece96c9a87d4a523d0fca672dd10e4aa12a508af77e2037"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.3/discrawl_0.15.3_darwin_amd64.tar.gz"
      sha256 "32dd0782990f4a24b4ce72dc60f30cdf6ff2d05c78e95a18cd930a279bbd6a51"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.3/discrawl_0.15.3_linux_arm64.tar.gz"
      sha256 "f4da99187284f46a7638af8ed21f70c8cfab9a5d67bd70fbe969354df5455a89"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.3/discrawl_0.15.3_linux_amd64.tar.gz"
      sha256 "b67c115fff9f7ae2f586a2540ba1cd87dda238b1e43368c10f6c3aa440559d36"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
