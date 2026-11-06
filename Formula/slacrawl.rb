class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.10.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.6/slacrawl_0.10.6_darwin_arm64.tar.gz"
      sha256 "ecf90ddbe3ebe7d5e3ec98f5fab43d444f1d5cd590e8c820b26d6b1f2e8ae921"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.6/slacrawl_0.10.6_darwin_amd64.tar.gz"
      sha256 "885f8816382b41a9cf8b3426817cea796197bbd21bbda01364075bd31f2bb4bd"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.6/slacrawl_0.10.6_linux_arm64.tar.gz"
      sha256 "11dd957ef9a10bc16665ba97760b0358f81617d7eb862639ae0f8f16cfb9c383"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.6/slacrawl_0.10.6_linux_amd64.tar.gz"
      sha256 "daf560f24e57949fe9ab8c7d33cbf1341a0c265afa9911dd904115800bae6154"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
