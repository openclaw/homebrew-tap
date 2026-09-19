class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.6.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.6/octopool_0.6.6_darwin_arm64.tar.gz"
      sha256 "88c2c3b1842457b0c78825948168d749d1cef21c8bf8a1e1c012393166554e2e"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.6/octopool_0.6.6_darwin_amd64.tar.gz"
      sha256 "c73f07d286bdb85b457e8d3dad3ffe0d89a37a8a1981481096b553dbea74c27e"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.6/octopool_0.6.6_linux_arm64.tar.gz"
      sha256 "5ec0a0a473d33aa7141910cc6b0fa1c4841993b35797dd2753e0c639725fb5f9"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.6/octopool_0.6.6_linux_amd64.tar.gz"
      sha256 "8d82b81bfd96c34a640147132d76b2c06d0b1cee893fe0c818c664dbec8d0824"
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
