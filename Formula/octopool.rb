class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.9"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.9/octopool_0.9.9_darwin_arm64.tar.gz"
      sha256 "8f85f9db4fe397425149d7ac85f2e0ce9dba981a8e5a6a4ba531902b4c09c339"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.9/octopool_0.9.9_darwin_amd64.tar.gz"
      sha256 "7ef4379aba7ed9b86a2bde1203be019f277ef3dc4da183c9c19c52fc3402e74a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.9/octopool_0.9.9_linux_arm64.tar.gz"
      sha256 "69a36fadf4f07309ac3d3018614bdae1a5958209d433fcc5c805960820866d95"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.9/octopool_0.9.9_linux_amd64.tar.gz"
      sha256 "136800cfe515498a5da682b269bd27bdf86cfcce18d8dc4813e3e3aa15b0d9ad"
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
