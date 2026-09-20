class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.6.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.8/octopool_0.6.8_darwin_arm64.tar.gz"
      sha256 "13eb05f6936c660c2063c040941a686de2d23445bac17acb35c6d683997281e0"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.8/octopool_0.6.8_darwin_amd64.tar.gz"
      sha256 "6fa79530d292f993a7b67e4651a1a9dca5fdcaa593b915ce06127ec69c1fbd84"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.6.8/octopool_0.6.8_linux_arm64.tar.gz"
      sha256 "d7a3b35f18fdf3ad7632f2651a57be1576a780a71b81d89de79b67579d7c11a1"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.6.8/octopool_0.6.8_linux_amd64.tar.gz"
      sha256 "2f41c3483c130f5cffcda393a8e18bb7a85abb83cd622a02435e42979b5b9e54"
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
