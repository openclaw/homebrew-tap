class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.8/discrawl_0.15.8_darwin_arm64.tar.gz"
      sha256 "23fb2b4b73981b7409b2d0af64a06bd2717788f32b2702debe3fae874e39098a"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.8/discrawl_0.15.8_darwin_amd64.tar.gz"
      sha256 "feb78ea0a00ea4e6574bf2aaea8c6dd166627e30b84cdb4fd15a2e744c03d1ea"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.8/discrawl_0.15.8_linux_arm64.tar.gz"
      sha256 "21165adf76522c0d002f689c01b9acb04ff918c0ec2d82828589a359b15cd9c6"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.8/discrawl_0.15.8_linux_amd64.tar.gz"
      sha256 "7658d45e17fc5d168fb6e71767de6bb5a3a15b036319c88bb2a8e11f74b66554"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
