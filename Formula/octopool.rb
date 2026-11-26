class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.10.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.10.0/octopool_0.10.0_darwin_arm64.tar.gz"
      sha256 "2a67a975a3baf6a9bd2648c281d48569df943a491e3fe7b82033ff239b4def7f"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.10.0/octopool_0.10.0_darwin_amd64.tar.gz"
      sha256 "e607be023c88003e6c6cec910a00e4829414968bb94747fa111b5dfa0e8c010a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.10.0/octopool_0.10.0_linux_arm64.tar.gz"
      sha256 "fcdbcf1f94159878b427d5f65629a23030bf7b6f67a6df792013304bf7651a48"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.10.0/octopool_0.10.0_linux_amd64.tar.gz"
      sha256 "caf4708e7b57e72bd2427dfc8e6f870f2cedb22024fe1a32e855b4167976e822"
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
