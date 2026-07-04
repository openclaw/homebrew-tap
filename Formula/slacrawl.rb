class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.5/slacrawl_0.7.5_darwin_arm64.tar.gz"
      sha256 "3814cef8826fb94a02c55ad3538a8460fc070868c3c6b52f5e4aa62e467dbcfa"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.5/slacrawl_0.7.5_darwin_amd64.tar.gz"
      sha256 "4fc1a640a2cd02b5d3e226cdefe1e4762fb3f73c49618d08277f2e784244afba"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.5/slacrawl_0.7.5_linux_arm64.tar.gz"
      sha256 "4a714b7bebea907c6938188764c675b9c439eba557a4a6e7168e56c112492d75"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.5/slacrawl_0.7.5_linux_amd64.tar.gz"
      sha256 "dbf6c41c855c8f40f4bcbea1e624e9cf94be9573b0531311c3cb65994f05054b"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
