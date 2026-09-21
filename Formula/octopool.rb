class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.7.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.7.0/octopool_0.7.0_darwin_arm64.tar.gz"
      sha256 "5bf911aebdb057c1389a096564deb3becdec9220a95585ab55d8ed99e68c215d"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.7.0/octopool_0.7.0_darwin_amd64.tar.gz"
      sha256 "c9e119206187d445691b52db0eb7500cb76629e66fe9a438ff2c0525473cb2d6"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.7.0/octopool_0.7.0_linux_arm64.tar.gz"
      sha256 "de241e89e3a1cdfa7cd9429dcc6fb298369e7c3fb9f08117aadaab65f322e372"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.7.0/octopool_0.7.0_linux_amd64.tar.gz"
      sha256 "efedbea89c91276112a090107c637157fc5ed0e1287369fbbf24adff22faf180"
    end
  end

  def install
    bin.install "octopool"
  end

  def caveats
    <<~EOS
      Run `octopool install-shim` to route gh through Octopool in every zsh.
    EOS
  end

  test do
    assert_match "octopool #{version}", shell_output("#{bin}/octopool version")
  end
end
