class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.23.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.23.0/gogcli_0.23.0_darwin_arm64.tar.gz"
      sha256 "0f7b5d254c03f83d21125a6f8283cf1aa0614a2a95e6b8f4e731611c2c8fe76f"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.23.0/gogcli_0.23.0_darwin_amd64.tar.gz"
      sha256 "10c4be69bac63f8c6e5044a1c553c0802a74916d24c93554c7485b68c7491f2f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.23.0/gogcli_0.23.0_linux_arm64.tar.gz"
      sha256 "e0eff68af1f31051e80f8225c36c123c8db2c2bf10bdd2e3e4108b4c43ea8f88"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.23.0/gogcli_0.23.0_linux_amd64.tar.gz"
      sha256 "c3c162b00b5bbadc4e005024a51be85cdcd1a01b17647fe88eb153330f6cff31"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
