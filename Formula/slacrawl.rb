class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.1/slacrawl_0.7.1_darwin_arm64.tar.gz"
      sha256 "9bc6e421685e2758b7ef266c3fb03fe87fa9465b0f7d12339bb986eda1a0a724"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.1/slacrawl_0.7.1_darwin_amd64.tar.gz"
      sha256 "b5758fe7c2143989200098f724de9fecbc162244520bed767e4c9fb7355ea5a8"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.1/slacrawl_0.7.1_linux_arm64.tar.gz"
      sha256 "22bc6ed5a2187a0d018667f797f350ac98ab92b6b2332872a3948d5fffebf225"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.1/slacrawl_0.7.1_linux_amd64.tar.gz"
      sha256 "84751dd471019b234d58d374060587aa81aaa47cf44f508537f8f28590a5163c"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
