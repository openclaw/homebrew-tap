class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.28.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.28.0/gogcli_0.28.0_darwin_arm64.tar.gz"
      sha256 "3ebd85b4a0a50d99b571e17d11b33d86fde87f1c82cee0face7f3a25c7a524b3"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.28.0/gogcli_0.28.0_darwin_amd64.tar.gz"
      sha256 "e0e55f360967860f1caeb2cdf434289eca8296f18335a3024e9710edd808727f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.28.0/gogcli_0.28.0_linux_arm64.tar.gz"
      sha256 "c28871511abc8de7588ea069d8090935221cc9c667956226eabcd1fc51d19dc4"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.28.0/gogcli_0.28.0_linux_amd64.tar.gz"
      sha256 "5076a41ef1fd09573e20559c1911de3ba7abcb08bff61788867a302d3d2d90d8"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
