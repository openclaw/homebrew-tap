class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.10.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.2/slacrawl_0.10.2_darwin_arm64.tar.gz"
      sha256 "3f9ac54513bd0b4e5e4e21fce1ff17536f9db8057379589be6f6db12f0e48859"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.2/slacrawl_0.10.2_darwin_amd64.tar.gz"
      sha256 "38e50176a9294e4ed6473eccda7dd25991ece1e5c90b359abd7f9617abcbf060"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.2/slacrawl_0.10.2_linux_arm64.tar.gz"
      sha256 "304c9cbf2fd7e8b66bfeab7f2affead48266581f84aabee4460d6ca345604e0e"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.2/slacrawl_0.10.2_linux_amd64.tar.gz"
      sha256 "d49314d65185ca83398c4667cb1689b60cca661e2e32eec6ec3fbea272e2164d"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
