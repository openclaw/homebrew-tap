class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.9.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.9.0/slacrawl_0.9.0_darwin_arm64.tar.gz"
      sha256 "36896963542458826ca6b480b11de4c9be3a9a7503ea5b6b91cc2fb2d3d7096c"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.9.0/slacrawl_0.9.0_darwin_amd64.tar.gz"
      sha256 "86d9c56d42da7237a0f9335378bf04c0034368612b9c56e82d20e76a89fbeb0d"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.9.0/slacrawl_0.9.0_linux_arm64.tar.gz"
      sha256 "a841cbe587fdafdf8f92a2f55eb7a79267d06c2334e4f1731a5cb725a087bda6"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.9.0/slacrawl_0.9.0_linux_amd64.tar.gz"
      sha256 "7b56bcb5f08a22f8957bd628f56072df49e213306b32d33d43bad3e18574d243"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
