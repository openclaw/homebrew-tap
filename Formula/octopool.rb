class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.3/octopool_0.9.3_darwin_arm64.tar.gz"
      sha256 "f990f2957abf0e2d0bfa2832de08b02fe5ca393d690255045b15689f8c73c0e3"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.3/octopool_0.9.3_darwin_amd64.tar.gz"
      sha256 "0b88e9ba1e07b52818b2b65b31d37f65fcb09a2424304a765aa6a048d7b2a88f"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.3/octopool_0.9.3_linux_arm64.tar.gz"
      sha256 "8e8c97f47966b7e0e480313e81ff32d81594021ddcd5f1060a12543a58bc9e09"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.3/octopool_0.9.3_linux_amd64.tar.gz"
      sha256 "49ef95b18e03bc4f34f337e083bfdcd6d5eb92fa15fc5bc72436607c8654aedd"
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
