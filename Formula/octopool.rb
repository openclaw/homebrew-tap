class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.8/octopool_0.9.8_darwin_arm64.tar.gz"
      sha256 "530a478b0cfa210481fa9b236b72a9394748c47c75287505b02d75e4485052ca"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.8/octopool_0.9.8_darwin_amd64.tar.gz"
      sha256 "4168743f4e25565bc72670de007706ecf1dcc0547c1589d62fe51a4e07fd7b44"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.8/octopool_0.9.8_linux_arm64.tar.gz"
      sha256 "a20c4da4c598162b490fd4c71d1a95d9ef10a914840f5a62b75a6dd56c3c8a3e"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.8/octopool_0.9.8_linux_amd64.tar.gz"
      sha256 "016d2c3ee425638cfb2ba9658efedbcb3b2b5958beab689ec53612647f35a2f3"
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
