class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.39.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.39.1/gogcli_0.39.1_darwin_arm64.tar.gz"
      sha256 "387062a590d470d0b13b1c79cab72c5908bfc42abc5cf68243bf3f12fc30acda"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.39.1/gogcli_0.39.1_darwin_amd64.tar.gz"
      sha256 "e927ddf46cbee95fd4f1cb0946458fcbfff68fe68754121c310cd3aa5aca286c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.39.1/gogcli_0.39.1_linux_arm64.tar.gz"
      sha256 "7c23b402c9234ba476e84b39ac6d875444b47ec516312a99e877e1386ba28295"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.39.1/gogcli_0.39.1_linux_amd64.tar.gz"
      sha256 "438efa460b8291f023299ad2ed5610701cad7508db88392039c0891e2175e3b1"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
