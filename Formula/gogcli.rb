class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.48.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.48.0/gogcli_0.48.0_darwin_arm64.tar.gz"
      sha256 "a8c6142fcb9f41f0eff02ffef78298cbe4981061f149c2b3a42d5a13bad931bd"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.48.0/gogcli_0.48.0_darwin_amd64.tar.gz"
      sha256 "423d8ac93530e13cd7cb599de2655db3262ddc763181996771d74188ffcefc5a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.48.0/gogcli_0.48.0_linux_arm64.tar.gz"
      sha256 "fc40524368d2cb6213bdfe0b736b5884e1b55c6368706d7a285542cb7e559b68"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.48.0/gogcli_0.48.0_linux_amd64.tar.gz"
      sha256 "8809d2f4fe95a0299b1a2a5c6bc912c4aba4b90a7b5e2c1f5cf11b9945a50004"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
