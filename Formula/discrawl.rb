class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.2/discrawl_0.15.2_darwin_arm64.tar.gz"
      sha256 "67a0f88a204154e115a0b8767ee9877190b0a0127143b54fa0ac495a76b20b8d"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.2/discrawl_0.15.2_darwin_amd64.tar.gz"
      sha256 "6f45d04dbab945c17b61af8f3930b0788354a8314e7596e87ddd3f7010684a23"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.2/discrawl_0.15.2_linux_arm64.tar.gz"
      sha256 "137c3ecefb000b2636ee415d7ef4fcde1ea70e2475815af641602c60bb02f576"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.2/discrawl_0.15.2_linux_amd64.tar.gz"
      sha256 "b4cb8d75fcdbc746d0f1c5d0343af70db5d53e66b228781d620664c17145b0d2"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
