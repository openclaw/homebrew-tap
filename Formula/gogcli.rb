class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.33.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.33.0/gogcli_0.33.0_darwin_arm64.tar.gz"
      sha256 "d73b324fa3a35a08175432761c8bfd410896b1a22365aa89890ac4fbfdf7c66e"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.33.0/gogcli_0.33.0_darwin_amd64.tar.gz"
      sha256 "259c4bf1f41bc725936eb816aac9d5c95df9eaf21be0a8df93a9c42fe55f83a4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.33.0/gogcli_0.33.0_linux_arm64.tar.gz"
      sha256 "1453362770b65eb8d63e31fe3677a93aa1e115a7d2c6628049fc477e903a526e"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.33.0/gogcli_0.33.0_linux_amd64.tar.gz"
      sha256 "865347e22a034dee7638e00852bc498658b74488759ef5223e4517cd3950e72d"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
