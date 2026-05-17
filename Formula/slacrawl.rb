class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.6.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.6.1/slacrawl_0.6.1_darwin_arm64.tar.gz"
      sha256 "566172633abd93bc59ba86e59a9832df7e5fe0cfc955a1fc8896ce7e4c9d0032"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.6.1/slacrawl_0.6.1_darwin_amd64.tar.gz"
      sha256 "79ed37eccddf0ef1cf50241df1ee7684a021d03c758b4714238fe7b589651194"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.6.1/slacrawl_0.6.1_linux_arm64.tar.gz"
      sha256 "4010491e1424b95174547872c22b17198d8c5ce26911b34887aa10d83efede61"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.6.1/slacrawl_0.6.1_linux_amd64.tar.gz"
      sha256 "982bf5fec930a6e5913c213c51b6055c8a4d66bdeeb69e70b0443fcb5e47484c"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
