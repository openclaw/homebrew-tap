class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.40.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.40.0/gogcli_0.40.0_darwin_arm64.tar.gz"
      sha256 "48d11e8e95c077a4b295b78b0cd33c93349b92a2f0337cace2aff2dd1a8ac07e"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.40.0/gogcli_0.40.0_darwin_amd64.tar.gz"
      sha256 "b953d88a84cf9a5d81f5f31bd76b76b930483a1b81c9574239065f7b5519a320"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.40.0/gogcli_0.40.0_linux_arm64.tar.gz"
      sha256 "21ca9757f67a573115b517854184561cef6b3b73c21e0f60c72229522c7198ac"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.40.0/gogcli_0.40.0_linux_amd64.tar.gz"
      sha256 "5f73815950f30de4165b7b767103ca45c4950e84a1da601eda5294e9ff94f767"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
