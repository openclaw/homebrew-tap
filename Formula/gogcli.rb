class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.30.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.30.0/gogcli_0.30.0_darwin_arm64.tar.gz"
      sha256 "f451c01dd5eed07958e3f9d40d1ba2c8df8d092a9fb1be5e5d3a9afdda358073"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.30.0/gogcli_0.30.0_darwin_amd64.tar.gz"
      sha256 "aa27f33a2de6e3d13ba2c49c88fa9d4b783844c9b6f0e2d67b9d2a8c449488fe"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.30.0/gogcli_0.30.0_linux_arm64.tar.gz"
      sha256 "3ba0ce1c268bc95cf84c60c622e1e4cbf3bc257ecd6e447bd1cfcdd3aa09430a"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.30.0/gogcli_0.30.0_linux_amd64.tar.gz"
      sha256 "f9f4f407bb762959085b42007c4da538b3dafc5c76b53f3a30dc7ff7c6237fc1"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
