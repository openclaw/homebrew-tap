class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.4/octopool_0.9.4_darwin_arm64.tar.gz"
      sha256 "e625272be8ea9b1e3a7b300f8f59e799c74018517ac787e532fe31a9ec5cdc67"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.4/octopool_0.9.4_darwin_amd64.tar.gz"
      sha256 "b18af42a06258ae032df5274e09c08e78760dc5ffb478f1ed242b62832cb697a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.4/octopool_0.9.4_linux_arm64.tar.gz"
      sha256 "53620fbbd287912de07b9b7215d82914dd5c8c76caf79a1358e704b04b1e3d6c"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.4/octopool_0.9.4_linux_amd64.tar.gz"
      sha256 "187f724d047f640ac7f437ca658f65f5702b47b166e6fd4dfe38b4f905210e60"
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
