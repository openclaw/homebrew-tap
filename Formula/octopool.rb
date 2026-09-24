class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.8.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.8.0/octopool_0.8.0_darwin_arm64.tar.gz"
      sha256 "07a6be3c75f81d1920db4310aa13d4a1361849ab698e009ee7905de4aa00ccd7"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.8.0/octopool_0.8.0_darwin_amd64.tar.gz"
      sha256 "9356b11d1ff45f312aa5f51d748e7fd9792042b80ce763c195a8ff86bf84e620"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.8.0/octopool_0.8.0_linux_arm64.tar.gz"
      sha256 "650031e797744fb03610fdb192d08972c33f296e1909a1b95ed86b056d31d66c"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.8.0/octopool_0.8.0_linux_amd64.tar.gz"
      sha256 "b6cd59862fc043a2fb2af32fcba0dff1a4e394f3325e6502425f002d1cf68bbc"
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
