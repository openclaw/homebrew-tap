class Clawdex < Formula
  desc "Local-first address book backed by Markdown"
  homepage "https://github.com/openclaw/clawdex"
  version "0.4.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.2/clawdex_0.4.2_darwin_arm64.tar.gz"
      sha256 "000ec234eb6c562bfc3ff15094d86ad50f361bb249eaa882337d19ab07af016a"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.2/clawdex_0.4.2_darwin_amd64.tar.gz"
      sha256 "c387cdc1813e011d571e61ccaa30027cbf20d9e108356f7d0547e86e822557ef"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.2/clawdex_0.4.2_linux_arm64.tar.gz"
      sha256 "b69cffa20242f6b241f7382d6c83c49c1e6cd5663eeca65701894de05482e5e6"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.2/clawdex_0.4.2_linux_amd64.tar.gz"
      sha256 "3d11b6f523e81e4ddddea91803839d52b1d38c3520867fada993d5b7c7bbc823"
    end
  end

  skip_clean "bin/clawdex"

  def install
    bin.install "clawdex"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawdex --version")
  end
end
