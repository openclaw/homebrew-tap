class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.6.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.6.2/slacrawl_0.6.2_darwin_arm64.tar.gz"
      sha256 "f2655d9b8c18959184a7237e249a59f4aa2681118ba286394f915d5b574b8455"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.6.2/slacrawl_0.6.2_darwin_amd64.tar.gz"
      sha256 "cee1789e783812195f1dc550d6aa2614e0ee612e1ed3a5cb1c9fa29b12973b63"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.6.2/slacrawl_0.6.2_linux_arm64.tar.gz"
      sha256 "c2749c82cd2ecc055d718ad7ee64a530022d49bd856220275f86935aa293a997"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.6.2/slacrawl_0.6.2_linux_amd64.tar.gz"
      sha256 "dbdbe886e106e53788a27acd4ce3e03d68f8c3e4cd08f23f0523c11e4071b157"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
