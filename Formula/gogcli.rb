class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.18.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.18.0/gogcli_0.18.0_darwin_arm64.tar.gz"
      sha256 "b0cac4023f0f6c2ad67e0df02d1f651f9b5b6ffe923922af02b3301d97de922c"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.18.0/gogcli_0.18.0_darwin_amd64.tar.gz"
      sha256 "6cd10b4c185c6d047df1c4500adaec99bee7346c143f7f4c1ac0c890b88e4225"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.18.0/gogcli_0.18.0_linux_arm64.tar.gz"
      sha256 "7874c8b98d4b46e57d25a5d6b0ab9dc71f7d4491a282c47d64be864108024ca5"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.18.0/gogcli_0.18.0_linux_amd64.tar.gz"
      sha256 "08d33c2e2845c83428d4ec6a4514898ac81c854cd520adf9cdf5ea17e1c0414d"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
