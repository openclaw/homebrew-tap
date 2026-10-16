class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.10.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.3/slacrawl_0.10.3_darwin_arm64.tar.gz"
      sha256 "8c96b2d5e1e6febc68bdc8c430044941a40f24649ef4b5a13a252967c5f73ffd"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.3/slacrawl_0.10.3_darwin_amd64.tar.gz"
      sha256 "1e50c7b258856bd4bc092bf80daec1c079df5e09240c0d4703464c59e6321de0"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.3/slacrawl_0.10.3_linux_arm64.tar.gz"
      sha256 "e47163733221aede99f89b95c6c7c8889c10f3b5eea89f7ff5b6a74a20b3755f"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.3/slacrawl_0.10.3_linux_amd64.tar.gz"
      sha256 "934417f19fc002fe7c1f7c78b0e0c40d4ee610bb4aa845fb36eea26d565a9b91"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
