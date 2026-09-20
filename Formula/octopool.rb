class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.6.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.7/octopool_0.6.7_darwin_arm64.tar.gz"
      sha256 "1a0dd966ef242803eb4c5ecb56d9a2a0b4f1d26911f037bbed0bb59849a408a3"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.7/octopool_0.6.7_darwin_amd64.tar.gz"
      sha256 "bce608f0bc16cd6250b28dfacdfe5ae5dedf723718019e451c5ecb0e0fa53437"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.7/octopool_0.6.7_linux_arm64.tar.gz"
      sha256 "0ef2c09cbd428a286d329203f2da0014012c847665c88a49933d32cb6e63bc70"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.7/octopool_0.6.7_linux_amd64.tar.gz"
      sha256 "e15074baaa9b3d1d8b79e2fff2defe9cf8d6af9ab21a391e2c1c2d4dc5ca589d"
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
