class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.7/discrawl_0.11.7_darwin_arm64.tar.gz"
      sha256 "cbedd9fdcc9e5812a83247745c943ac48dc00a43fc918cdbbd33c1b27c2f6980"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.7/discrawl_0.11.7_darwin_amd64.tar.gz"
      sha256 "66a61222f7767747ac9fe5459e0e4f1cb50c6b35bc54db3dbf7a6b89da5243d9"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.7/discrawl_0.11.7_linux_arm64.tar.gz"
      sha256 "822c573e14514e0b85e5cc15e3e33d639ddf872ee352d33924192b1ad5cd60c8"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.7/discrawl_0.11.7_linux_amd64.tar.gz"
      sha256 "933064dc9a84a0dd4b407037cbb436cc269d90731946a923231072990800fba1"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
