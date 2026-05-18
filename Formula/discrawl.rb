class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.9.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.9.1/discrawl_0.9.1_darwin_arm64.tar.gz"
      sha256 "b66a74892117ab88f2c69a33a1dfd71c731475fe88e79c736a51a4cc3b986eec"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.9.1/discrawl_0.9.1_darwin_amd64.tar.gz"
      sha256 "fee47c3b2795a67b01e35a42cb8a73f029640e6c2d48dd52d10263a278c8be11"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.9.1/discrawl_0.9.1_linux_arm64.tar.gz"
      sha256 "f9ae1c897e7a76ae3b3ef537beb36ca95886590215d1a4c36c8cae92ee509a9e"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.9.1/discrawl_0.9.1_linux_amd64.tar.gz"
      sha256 "927cfcb90777405970f2ab4f5d8881bfff8c755fc34942f9b2ce4eba331f71fb"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
