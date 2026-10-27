class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.18.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.18.0/discrawl_0.18.0_darwin_arm64.tar.gz"
      sha256 "dcb74b8e45078ac215875b6f2bf136b2e6c5d64b6d9ffa37dae5bf1f92897ad7"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.18.0/discrawl_0.18.0_darwin_amd64.tar.gz"
      sha256 "2daa048096f97a70fe0b9f083d658d8364bb1ff9f54087e638c4892c29b828c6"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.18.0/discrawl_0.18.0_linux_arm64.tar.gz"
      sha256 "9b3198b14b9896b4145d4f7a9ad79246682ad8ddba9e4f487fc212e4a9b6b6f0"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.18.0/discrawl_0.18.0_linux_amd64.tar.gz"
      sha256 "6c6218d3c47e5fc1c1e67e45b3f51d4c5a2bc66a535bccba2f67a34e061c4328"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
