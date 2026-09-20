class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.6.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.9/octopool_0.6.9_darwin_arm64.tar.gz"
      sha256 "5c7081318a2206a31167465aa2a5cfea34c414bc47f248eb873fd515aa6b11a4"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.9/octopool_0.6.9_darwin_amd64.tar.gz"
      sha256 "1bf43ded2e2ba67fa3fff284332a020c1f59b503c6ee93b69baf442b5c5c5bb7"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.9/octopool_0.6.9_linux_arm64.tar.gz"
      sha256 "8f4be253b34e9dfaa26dae81ba5b9c535554a6e80551dce957342d9250578a8e"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.9/octopool_0.6.9_linux_amd64.tar.gz"
      sha256 "1b71a097f66dd804d4770e585cc122969cc2ce24e86cd771b426527620eff1f6"
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
