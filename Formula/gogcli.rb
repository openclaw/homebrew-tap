class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.20.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.20.0/gogcli_0.20.0_darwin_arm64.tar.gz"
      sha256 "e991470c8d7f190f099565914ff2eacbd688fc2abce144cd2496ebf25c3c04ac"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.20.0/gogcli_0.20.0_darwin_amd64.tar.gz"
      sha256 "10f82a796358699697af8b95603803d04c206311db647ed2286ea49ad1866b2b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.20.0/gogcli_0.20.0_linux_arm64.tar.gz"
      sha256 "1cf56ad5649759b90cb67537c84b598a43794d6dd0d85b280495c10f6ff941c7"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.20.0/gogcli_0.20.0_linux_amd64.tar.gz"
      sha256 "8c78431d5a4286aebb04887a9c9cb6183f88ea0fbbf3bf1802c8af1b5a673a67"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
