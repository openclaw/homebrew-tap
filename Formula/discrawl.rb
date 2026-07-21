class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.8/discrawl_0.11.8_darwin_arm64.tar.gz"
      sha256 "90071467ab86e96758535b05d6889afb8081640d3f1d1791e95371f22c1f01c9"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.8/discrawl_0.11.8_darwin_amd64.tar.gz"
      sha256 "57c524d2e4e6b5906254c964296b93686a402581f85756c5083d566dbbf34c04"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.8/discrawl_0.11.8_linux_arm64.tar.gz"
      sha256 "c93275235cffcb6448fb1ffbaca4b085e815e49374f5e744d0f1c0a8d2674ef4"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.8/discrawl_0.11.8_linux_amd64.tar.gz"
      sha256 "6cd5e4acece373d29a167bb155025f5d5c9f5be6e8997f1765ad355da6248b3c"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
