class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.19.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.19.0/discrawl_0.19.0_darwin_arm64.tar.gz"
      sha256 "0791da72c00e49c00fb95cf17b1aa1d64d0d3d5b9af30269207ba121d52fbdc4"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.19.0/discrawl_0.19.0_darwin_amd64.tar.gz"
      sha256 "f0e7ebefc456c3cb5e39da307bc4181f2a14f44a40fc1ef57a0eac838785bdf5"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.19.0/discrawl_0.19.0_linux_arm64.tar.gz"
      sha256 "fb1b4626d41bc36e8c447f275d783c75624adccd941819d04416669a9597d2e7"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.19.0/discrawl_0.19.0_linux_amd64.tar.gz"
      sha256 "20a339c91ce6345a2ef0dd8de17953d1c52964d3dfcaaad5ea86acc17f04c2a5"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
