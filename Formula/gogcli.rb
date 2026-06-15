class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.27.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.27.1/gogcli_0.27.1_darwin_arm64.tar.gz"
      sha256 "a0d5c737c6180ba3c60a6c17ca5ee11c6705161d4884ac579d4c46f7b7718e34"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.27.1/gogcli_0.27.1_darwin_amd64.tar.gz"
      sha256 "17088ee3bcc4ad25b2ff6e9624af18bc0ebd85e9acc130529323c486d5648dfb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.27.1/gogcli_0.27.1_linux_arm64.tar.gz"
      sha256 "62c59abcc7bd53c4ac6d0219b4258d77b33d4f5b215a24b966e541b5718ba8f2"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.27.1/gogcli_0.27.1_linux_amd64.tar.gz"
      sha256 "aee2b477428e81633a1af77226ea3b31ab0d78a7137a057bb131cd1297b588f5"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
