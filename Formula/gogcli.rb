class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.34.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v#{version}/gogcli_#{version}_darwin_arm64.tar.gz"
      sha256 "90ab9104d543d16ac5367d405dc61b886003a118ce7eaddd0dd73c0363141449"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v#{version}/gogcli_#{version}_darwin_amd64.tar.gz"
      sha256 "14ae529f1ca9404252c5606689cd1e40a02b7357ca60f6491d9c85937342d3d4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v#{version}/gogcli_#{version}_linux_arm64.tar.gz"
      sha256 "8510db6492c27f7704bf60af276f34ede81b67d88b6ffcf953153da841eaa3ed"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v#{version}/gogcli_#{version}_linux_amd64.tar.gz"
      sha256 "a5b4be2ea635d4c830972dec1f3a90b0ca17f9c25e7a6353d1e068d8505ea983"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
