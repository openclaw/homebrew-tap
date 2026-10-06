class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.6/octopool_0.9.6_darwin_arm64.tar.gz"
      sha256 "1f7dc34f03ecf4c28f5028aa43608bc7901f4ff3e0cf222e481869d3e9e89109"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.6/octopool_0.9.6_darwin_amd64.tar.gz"
      sha256 "63dfabad21b7a3a3ab80e2d8f0400ce6e82b5f6f54fde2dd93cd795192bf8b46"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.6/octopool_0.9.6_linux_arm64.tar.gz"
      sha256 "f04ffda65b18fba2aabbdf48bd55978186319d658bde62ede51dc0341e2f43c5"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.6/octopool_0.9.6_linux_amd64.tar.gz"
      sha256 "8d7d7c2d666e5d643fb1d8995de13c63f6be70c430de4e5986dcecb220d2b707"
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
