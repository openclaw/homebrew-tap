class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.2/octopool_0.9.2_darwin_arm64.tar.gz"
      sha256 "c79d826b643f022e382938c2563b0d1ab92b19a63cf4cfad90a806c3c8dbea64"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.2/octopool_0.9.2_darwin_amd64.tar.gz"
      sha256 "716ac8b85be2b78fdc7d8da4351a900dff1d4979b54e948b53bdc33d9a2850f8"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.2/octopool_0.9.2_linux_arm64.tar.gz"
      sha256 "7da8b5293b29646a0ee31774f461fa1a10468961d27a5f3d56a00fcfc53bea0e"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.2/octopool_0.9.2_linux_amd64.tar.gz"
      sha256 "15da5481a3078fe87ca8da8b0cf3925319dfa11623ff57d1dd31f51a87c408c2"
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
