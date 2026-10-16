class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.5.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.1/telecrawl_0.5.1_darwin_arm64.tar.gz"
      sha256 "b96f751c5b1636271645041133e02a49c75b84b582c46db50e1034b105c2e3ca"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.1/telecrawl_0.5.1_darwin_amd64.tar.gz"
      sha256 "334666d9078919b59d3430c035173006f74651a53a4a6dfa7d3df58e848ca0d4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.1/telecrawl_0.5.1_linux_arm64.tar.gz"
      sha256 "1041df8de0d76e219d8107f7a558d05b8746feaba5c39940b025d9f1c2ef2023"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.1/telecrawl_0.5.1_linux_amd64.tar.gz"
      sha256 "4f1f5bd0da0ad1387244e4702eeec719dbc4d23d1fe5806927b00eedda2022c2"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
