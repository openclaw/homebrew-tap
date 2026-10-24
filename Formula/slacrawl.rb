class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.10.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.5/slacrawl_0.10.5_darwin_arm64.tar.gz"
      sha256 "df0151841bb5df8ad944652671dd0230297e7d41778eb36023437961626f4196"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.5/slacrawl_0.10.5_darwin_amd64.tar.gz"
      sha256 "3395b08c8291ddd3e3a457f824c0399adcab5d6aaabbbe7586da93ded881ea16"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.5/slacrawl_0.10.5_linux_arm64.tar.gz"
      sha256 "fde4960f6529f538b9019d1876765479624d8e0a944cc58ff75da0fa481f4f7d"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.5/slacrawl_0.10.5_linux_amd64.tar.gz"
      sha256 "776d58c0bf21fca41fb8492ce58ef17751014db3f552e722b6be26ff80ed85ae"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
