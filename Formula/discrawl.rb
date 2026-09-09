class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.14.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.14.1/discrawl_0.14.1_darwin_arm64.tar.gz"
      sha256 "8bdf4f5637f9c89b006de68f6ebfb8e809d24e792c270a14937001f1d9b2b5c3"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.14.1/discrawl_0.14.1_darwin_amd64.tar.gz"
      sha256 "210235fae801ff9b8db3d0562547b2b52e9f09846218dd9174a60601d7ec38ec"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.14.1/discrawl_0.14.1_linux_arm64.tar.gz"
      sha256 "045abdd6a6402a76d4ea3ba2897add098ca437c799312fd1a687b359369842c3"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.14.1/discrawl_0.14.1_linux_amd64.tar.gz"
      sha256 "b44d6806578b9b5ca29f0e09cb6294979f076bf59cb3ef4a4349fe23c10ccb10"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
