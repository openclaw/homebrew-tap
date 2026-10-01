class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.0/telecrawl_0.5.0_darwin_arm64.tar.gz"
      sha256 "0d759ec227b317fc0b684fa4baa2fa0d40dc407bd0d812379db127187783c4bd"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.0/telecrawl_0.5.0_darwin_amd64.tar.gz"
      sha256 "6b96170a508c53b034aacb0cc6e849b3186e7722be8037bb15e46919192a1c57"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.0/telecrawl_0.5.0_linux_arm64.tar.gz"
      sha256 "4bc43e1cec057899b2cf52169a4a51eefd20dc172924f347fc976618e8bfdb5e"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.0/telecrawl_0.5.0_linux_amd64.tar.gz"
      sha256 "de2671f5bf93acf5e14dd776331f276db4d4040b16908a375859e767a633c332"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
