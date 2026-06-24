class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.31.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.31.0/gogcli_0.31.0_darwin_arm64.tar.gz"
      sha256 "ee811a8db2b4eebdca083830a386578231e74761720dba167152c85388b587e8"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.31.0/gogcli_0.31.0_darwin_amd64.tar.gz"
      sha256 "53ebb07767988244e172cfb8b6f3a1e1057e86284e62500ae4379cfb114742f0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.31.0/gogcli_0.31.0_linux_arm64.tar.gz"
      sha256 "17b35aacb9969a423007ba4452780eedf2017234485acff34629a107b5567c0a"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.31.0/gogcli_0.31.0_linux_amd64.tar.gz"
      sha256 "f8d6f70e730ff4ca5680b0a664b397e6f0ebb2e87f2873a1ce81950b5eb38484"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
