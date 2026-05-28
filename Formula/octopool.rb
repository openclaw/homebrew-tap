class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.2.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_arm64.tar.gz"
      sha256 "49aaa508378ca5c03364c59dd7b7f98425cbe6719e9bd36d69cd2494b8930052"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_amd64.tar.gz"
      sha256 "6f5cc739d3eca5b08142797930a2b241cbc06156050b81699e7f4d3db1c65e9f"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_arm64.tar.gz"
      sha256 "f33dcf77ee5db38ef4c48c0595ce711c8abd309ded7ec611ddc1d4649c511045"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_amd64.tar.gz"
      sha256 "2a6d438c3dc01f094b05d02a9e94f65d2c4568b48ef75611ca9e4076ceb84839"
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
