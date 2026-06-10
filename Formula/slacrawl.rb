class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.2/slacrawl_0.7.2_darwin_arm64.tar.gz"
      sha256 "540457bd9dd749b8518072e3889dfa6fd2f5350b2598b35ff4a7ffa0583eea8f"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.2/slacrawl_0.7.2_darwin_amd64.tar.gz"
      sha256 "a7213eb375612d896889ada66053c7611fa0afada35743a7471e5da083d6ebae"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.2/slacrawl_0.7.2_linux_arm64.tar.gz"
      sha256 "f3daa8bfa4322553bf3a43e705a5bd860892131071bd951387aa378bbab24be9"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.2/slacrawl_0.7.2_linux_amd64.tar.gz"
      sha256 "171eb9bf86e3acc4c0f531d048491c96e5ff1773b32d55f3b79d02916a8fbb60"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
