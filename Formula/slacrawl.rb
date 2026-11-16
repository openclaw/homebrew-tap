class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.11.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.11.0/slacrawl_0.11.0_darwin_arm64.tar.gz"
      sha256 "205a185b7a57cac66721b98dcb21ccb9c2f87abccb94c8618afa1513d5f42e82"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.11.0/slacrawl_0.11.0_darwin_amd64.tar.gz"
      sha256 "e39ba6754d1bf5417cfeeaa2e5dcd7627b1957b5f2d542f2ecfb8fd1bfbdf479"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.11.0/slacrawl_0.11.0_linux_arm64.tar.gz"
      sha256 "8eeb09d03e003e6536ab9e8cc7a8ae4f1f9bf1163b08ba9d5f9b7a5b35e8be5a"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.11.0/slacrawl_0.11.0_linux_amd64.tar.gz"
      sha256 "9b032e4d6b579821de769faea5c270c92d6bb8c40ac412676d62a55be8089017"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
