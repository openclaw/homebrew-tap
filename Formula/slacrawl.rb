class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.9/slacrawl_0.7.9_darwin_arm64.tar.gz"
      sha256 "37e884c41e8e75960e0672605738268243e8cba2fb9f254b3a2e2c68b2c1e374"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.9/slacrawl_0.7.9_darwin_amd64.tar.gz"
      sha256 "b6418cd9fcaa66f8734eb35c7d294f1c54431230da97cbadf6e6f197485c8d88"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.9/slacrawl_0.7.9_linux_arm64.tar.gz"
      sha256 "023f387c0133fa5e325ca40e4f6a508d06ff7d9f2ffe5882c5dade0ad7944718"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.9/slacrawl_0.7.9_linux_amd64.tar.gz"
      sha256 "222d7b2c1f506c52e9f4fa6bda20a3b88b83bda11ab369bd797e703fa1321f8f"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
