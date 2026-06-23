class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.2/discrawl_0.11.2_darwin_arm64.tar.gz"
      sha256 "bc8e3e4a07255cafdf779161a1423027f328beb49a333c817423f6fe5876f96c"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.2/discrawl_0.11.2_darwin_amd64.tar.gz"
      sha256 "3ec8fb448eefe1db39899e462986472d702129f6a1bbb8d052bb7cbc5120eeda"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.2/discrawl_0.11.2_linux_arm64.tar.gz"
      sha256 "36331af416880dea5e2561695fcdfdc1c4a49a9d9ebf9f5908decdcf55a1e83d"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.2/discrawl_0.11.2_linux_amd64.tar.gz"
      sha256 "4d7fa4afa336b9ffcb22275d77c2840f6b985fbc7867d215f29e7e4649229b74"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
