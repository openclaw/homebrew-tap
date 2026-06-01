class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.21.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.21.0/gogcli_0.21.0_darwin_arm64.tar.gz"
      sha256 "e7dfdc22c33e945489089026f01f34fb7e954fe3a74081c7ee6751c69af72929"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.21.0/gogcli_0.21.0_darwin_amd64.tar.gz"
      sha256 "fa1a6d9b3299247d8774074c6cd2aa3643ff6e4864d8a325a3935456dd1d931e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.21.0/gogcli_0.21.0_linux_arm64.tar.gz"
      sha256 "1956b6cc479f28d25bc1e955c856aeed44b05c9504684d13d91837ac2027670e"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.21.0/gogcli_0.21.0_linux_amd64.tar.gz"
      sha256 "6131f3ee23aeb14e0b868c8ef2d2f2d6b158e834155e6f4631e2791cf3acb227"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
