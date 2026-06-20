class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.3/slacrawl_0.7.3_darwin_arm64.tar.gz"
      sha256 "166594b07b88193d1a0254803f5f4668a67d1a267f6eb366a04829e0bceac17f"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.3/slacrawl_0.7.3_darwin_amd64.tar.gz"
      sha256 "00f69ffbd5ea252076d8e68f699d4921901ff5166585d639ec91cd8f0aff269a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.3/slacrawl_0.7.3_linux_arm64.tar.gz"
      sha256 "9329a41455b8290ce64d92a6b4aa238931af18c416265be17b7f07d219e14d8d"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.3/slacrawl_0.7.3_linux_amd64.tar.gz"
      sha256 "db9a81a09b144702ec34be5d9c038dc760606eb5e6a8bd747090974d55ce6e51"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
