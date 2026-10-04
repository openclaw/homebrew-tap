class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.5/octopool_0.9.5_darwin_arm64.tar.gz"
      sha256 "c597d52dd4a41e9b650a3b12d796edf685674bfec904b812e7c8e73e3cb7deb5"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.5/octopool_0.9.5_darwin_amd64.tar.gz"
      sha256 "df4d542e17578f2660c7a4ccfb83fa897fce98ed7419a8e77d87fed904cad250"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.5/octopool_0.9.5_linux_arm64.tar.gz"
      sha256 "84aabc2ad6ea392d2e65b4ea3f3552edbb288c25953590aa99545f0a8b712530"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.5/octopool_0.9.5_linux_amd64.tar.gz"
      sha256 "f8e51a724ad3fb84dca2b46f3c8988a8a710790ff9dd7cde9524d967435c8507"
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
