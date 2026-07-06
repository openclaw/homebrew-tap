class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.6/slacrawl_0.7.6_darwin_arm64.tar.gz"
      sha256 "93bd7cc956237456e29e9fa41f8ee7e43ab026a6d45e96bf17da7c24b9e79a68"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.6/slacrawl_0.7.6_darwin_amd64.tar.gz"
      sha256 "9bccd263f271625cce90215690039086afeb5496d9e84f5b89c51a5d74a3f6df"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.6/slacrawl_0.7.6_linux_arm64.tar.gz"
      sha256 "8729c689d98349bab9d6ac53214289dbc935c80555c41d90993aa4b174af7b5c"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.6/slacrawl_0.7.6_linux_amd64.tar.gz"
      sha256 "cbf3548629d7e1f44b00c1f49f6da91fe9fe785c652a24052acfa3271ffb1044"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
