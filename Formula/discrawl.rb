class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.17.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.17.0/discrawl_0.17.0_darwin_arm64.tar.gz"
      sha256 "c21a0ee2427b18e88e01e8dcf3ab308fd0a4969bcfc4c6c52933ef67bdaae41d"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.17.0/discrawl_0.17.0_darwin_amd64.tar.gz"
      sha256 "c6ebe9613aeb61766f9325889638e862a1e809caa28ab0d43ffc1d2c473e1432"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.17.0/discrawl_0.17.0_linux_arm64.tar.gz"
      sha256 "fb977cd6266df20bbdaa296d660e56b9fe55f4a225c603f351a98640462ee4e1"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.17.0/discrawl_0.17.0_linux_amd64.tar.gz"
      sha256 "bc3010721f7e2a35766a41663cbcc6f4611fe211f53a13104d7caaff317a0e3f"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
