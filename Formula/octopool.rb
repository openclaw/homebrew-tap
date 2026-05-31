class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_arm64.tar.gz"
      sha256 "1d28ce4e4509cbbf69770cd24498bef444107e59aabddaa221191a4bde57afab"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_amd64.tar.gz"
      sha256 "1f7536eec55535e3577f6a12f756a3245c8b9018ab2ad4d905b547446141354e"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_arm64.tar.gz"
      sha256 "0d8a09537c1b29602bbfea51c457d9b3cc747984a7c0ad3fec466949a4918d9f"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_amd64.tar.gz"
      sha256 "c3c3049e76f156dfdb1bf4c6b9dd823fb3e90d468a99f2c3c2f0642bcdead394"
    end
  end

  def install
    bin.install "octopool"
  end

  def caveats
    <<~EOS
      To use the GitHub CLI shim, symlink the same binary as gh
      and set OCTOPOOL_GH_PATH to the real GitHub CLI if needed.
    EOS
  end

  test do
    assert_match "octopool #{version}", shell_output("#{bin}/octopool version")
  end
end
