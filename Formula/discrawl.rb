class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.5/discrawl_0.15.5_darwin_arm64.tar.gz"
      sha256 "39fb133c0df13fb93d245edf10b4b234e6b1d0c3ef95c2a7a2d9dc5a38441120"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.5/discrawl_0.15.5_darwin_amd64.tar.gz"
      sha256 "3a87f36a2ea9c02abcbe67bb7f1adde9435fe73423674b4869f546fa2a63987a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.5/discrawl_0.15.5_linux_arm64.tar.gz"
      sha256 "d79d446a956c9673b28d85105f97df30a2dd6fb0928cb78deb435779017fd84d"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.5/discrawl_0.15.5_linux_amd64.tar.gz"
      sha256 "a5c8c0ba364f85b1532733a87230aef8e43c17d451ac70faed8fd588484f4d49"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
