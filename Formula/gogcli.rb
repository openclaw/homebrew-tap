class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.27.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.27.0/gogcli_0.27.0_darwin_arm64.tar.gz"
      sha256 "6246bc1d95e54bf964d8a0213c124c86f37ef474ba5432aeb0714d150e808029"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.27.0/gogcli_0.27.0_darwin_amd64.tar.gz"
      sha256 "6b1ff31bddcd381416399915abb6c6dfef960f8c2c5847a55e3f970f12af4700"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.27.0/gogcli_0.27.0_linux_arm64.tar.gz"
      sha256 "1b43a4d266d3bbf978e2435b91924a36a38f28d65cb9928771228d5f0974f65a"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.27.0/gogcli_0.27.0_linux_amd64.tar.gz"
      sha256 "b5e2291e720782b28752e1da945cac8aa9a51421037c8a19f1544dcc8c169ce9"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
