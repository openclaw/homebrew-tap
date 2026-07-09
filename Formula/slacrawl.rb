class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.7/slacrawl_0.7.7_darwin_arm64.tar.gz"
      sha256 "11dac59f58c6fcfacf2bdbaff547873714cb0773dc26448893839903003553ba"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.7/slacrawl_0.7.7_darwin_amd64.tar.gz"
      sha256 "a833849bddd691fe28998f066f81a057714ab4e4d7925af770db67382cf4f8ed"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.7/slacrawl_0.7.7_linux_arm64.tar.gz"
      sha256 "573f453f59d4c549f09506bb1d1a97398ed183f83bd75f5f8422f682537acc11"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.7/slacrawl_0.7.7_linux_amd64.tar.gz"
      sha256 "4804f06d00cadc07d64c9859c16146bd6c1e2dfacdcbedf20aa120448b6046d1"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
