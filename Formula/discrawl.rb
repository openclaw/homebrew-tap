class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.1/discrawl_0.11.1_darwin_arm64.tar.gz"
      sha256 "61189a266b448108e5148bd50bc3f609effcb8d2619c53d01343e6589bec51e9"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.1/discrawl_0.11.1_darwin_amd64.tar.gz"
      sha256 "45b875d3aff27e06c61b1d547d275ab1c97457e681af72afeeea3a99407d16e6"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.1/discrawl_0.11.1_linux_arm64.tar.gz"
      sha256 "533d3ca1f369a831e0e32ae26649c8943c8932363f2b0a600e35daba59f28724"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.1/discrawl_0.11.1_linux_amd64.tar.gz"
      sha256 "bf076ce8aea41f25d6c4daa2f0a5532cfc143201b3a41f12dd3e912dec0cd005"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
