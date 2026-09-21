class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.6.10"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.10/octopool_0.6.10_darwin_arm64.tar.gz"
      sha256 "b19838c5dc35b1df4e5b6de74daf22ad77dbbb715d62afe1184f7d28acdb53e8"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.10/octopool_0.6.10_darwin_amd64.tar.gz"
      sha256 "d56b710d9fd78a022334a681213ff5240db28fcd5b86fb0ef56bd4aac48dd72e"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.10/octopool_0.6.10_linux_arm64.tar.gz"
      sha256 "4b4f00ce08b5fd7fdf438d35b08104e02addca48d0ecac14c2857606ba08e6f2"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.10/octopool_0.6.10_linux_amd64.tar.gz"
      sha256 "c108d30fb5e013e0a3296d2bd6112115e07c13c74a61e69a0cf5899b9a5489fa"
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
