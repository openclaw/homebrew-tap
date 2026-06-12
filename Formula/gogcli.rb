class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.25.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.25.0/gogcli_0.25.0_darwin_arm64.tar.gz"
      sha256 "4614caf89d597a84678599942580a521fd84e34137ef6caed883d11580d18e13"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.25.0/gogcli_0.25.0_darwin_amd64.tar.gz"
      sha256 "df0d3653dfeb78074bd10c98cc40bc2a7faaca6deaf72d1e68826ce0820ced3c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.25.0/gogcli_0.25.0_linux_arm64.tar.gz"
      sha256 "7274d268e08ffce11e16bc7af2369eb395e6e384d40a7e88d805c7229acf3261"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.25.0/gogcli_0.25.0_linux_amd64.tar.gz"
      sha256 "ef4a33c8ca50ace668bff4225a182fbac417be1f5e7660f74ac5b41c4ecdd219"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
