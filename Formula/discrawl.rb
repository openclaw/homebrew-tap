class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.0/discrawl_0.15.0_darwin_arm64.tar.gz"
      sha256 "b1c42ced95165a0f57082dbf4062b6156992e2385bf99a3e801f308a394b2bf0"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.0/discrawl_0.15.0_darwin_amd64.tar.gz"
      sha256 "f06cb666e59f8e0ed6bf2d74640e4dd4943b42fda1367690e9419c4a96326fc6"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.0/discrawl_0.15.0_linux_arm64.tar.gz"
      sha256 "a53337d428531700f2c10e8232e40417aa256e4083df73916ce561114419e5cf"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.0/discrawl_0.15.0_linux_amd64.tar.gz"
      sha256 "8b7ca02b9822b2173249b8087e7bf54f4c47366b8c6eb0c9ef1d25b925d57da2"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
