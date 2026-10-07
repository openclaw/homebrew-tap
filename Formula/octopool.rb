class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.7/octopool_0.9.7_darwin_arm64.tar.gz"
      sha256 "9c7c1d411d21a5c67d935f789821ebe0dab5c9e6780cd447afaca4e533a3ab44"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.7/octopool_0.9.7_darwin_amd64.tar.gz"
      sha256 "da340e0e00d8db329ec5bf4cb5fe8b8f6005c0eacb01f301b0622feb976d0903"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.7/octopool_0.9.7_linux_arm64.tar.gz"
      sha256 "d44833783161b0655240ed650961c53351faf5d518ab388c97a147aa7317315a"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.7/octopool_0.9.7_linux_amd64.tar.gz"
      sha256 "35f1501739757358a8283119dbdafc8e456618ec5d1fdcc6d21f422d03531f19"
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
