class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.4/slacrawl_0.7.4_darwin_arm64.tar.gz"
      sha256 "8c30816cd2ad298a009819736a4e2c54c00fc8678289d7bd8f7fbb2961442d08"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.4/slacrawl_0.7.4_darwin_amd64.tar.gz"
      sha256 "f17abf616ae5794069cc9b46f4ad4bf1ba5c5de34e62d58bfae769bfc68636ac"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.4/slacrawl_0.7.4_linux_arm64.tar.gz"
      sha256 "f30b9371df98adda0901bf5b874e874c76e8683a5bd501818834fe865d00707a"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.4/slacrawl_0.7.4_linux_amd64.tar.gz"
      sha256 "f0dcf8ae3d48cf177dd9831800836d4a7bf886c67630bcd1f74affee8bee847d"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help", 1)
  end
end
