class Goplaces < Formula
  desc "Go client and CLI for the Google Places API (New)"
  homepage "https://github.com/openclaw/goplaces"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.14/goplaces_0.4.14_darwin_arm64.tar.gz"
      sha256 "7326696ddc23bf7956ef1a288dfd8cfcfd93b559411734d6452ee6f40291504d"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.14/goplaces_0.4.14_darwin_amd64.tar.gz"
      sha256 "398ee962fd1e7f835de635ae99b26307de6fd76d4b3f38d8d5ff25b6a000ad77"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.14/goplaces_0.4.14_linux_arm64.tar.gz"
      sha256 "a377e9df67495177e1358090f0ad2779b0604071d1662f6943fd524b55a08995"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.14/goplaces_0.4.14_linux_amd64.tar.gz"
      sha256 "e34230d96e9888f8cfbf43d0d816415f6cb82f43c36227d12baec7d992796b7f"
    end
  end

  def install
    bin.install "goplaces"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goplaces --version")
  end
end
