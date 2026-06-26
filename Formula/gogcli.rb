class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.31.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.31.1/gogcli_0.31.1_darwin_arm64.tar.gz"
      sha256 "a330742ff92a740746109cb03338d2fed477a1b3f4d8416bd651578f71c31dc9"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.31.1/gogcli_0.31.1_darwin_amd64.tar.gz"
      sha256 "eea70c8e174ac27255734e25f682bf014d5952a75bc1462905b33f0d7f7312c4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.31.1/gogcli_0.31.1_linux_arm64.tar.gz"
      sha256 "705c43c48bc39297f0014344a47214532dd998698e5a4855247388cdfbf9498b"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.31.1/gogcli_0.31.1_linux_amd64.tar.gz"
      sha256 "5f5c35eb8c5603a59ee1eaf31909463f4e8c5f645130d9a4296571966a77aef2"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
