class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.10"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.10/octopool_0.9.10_darwin_arm64.tar.gz"
      sha256 "efa83f2a6103f0e0e0f20cb341b24d9519f358f806f1a7bfe69a25894f5169a9"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.10/octopool_0.9.10_darwin_amd64.tar.gz"
      sha256 "581fadf4f36a6fa02bc0aa35b348e3c2c3746160466e96f6244bca315b4e6158"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.10/octopool_0.9.10_linux_arm64.tar.gz"
      sha256 "9d42ca259bbbf6bb080c469389d8dba5af86cfb4cb514f4101f24bec7058c1b0"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.10/octopool_0.9.10_linux_amd64.tar.gz"
      sha256 "52c9e58d025bd36184d087ef437126165ecf934483f0f31d5249c29b90d1dc9f"
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
