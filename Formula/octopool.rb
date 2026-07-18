class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_arm64.tar.gz"
      sha256 "23c155e6535644697009199ab1647280ea4b93f40d0ef0e150c176e7a6335042"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_amd64.tar.gz"
      sha256 "04fa642442d045b11d2e45ffe446616fadf5fdda87a00965ad6a0e1310541f25"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_arm64.tar.gz"
      sha256 "78b31dfc56707a50210b2895748d89afd0a0b25843b14177154845fe565ea0fe"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_amd64.tar.gz"
      sha256 "c5cd3202d6c9ca7d0bc756d22e44350157bb572cb627d6be642a3c53e4db10c4"
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
