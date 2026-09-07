class Clawdex < Formula
  desc "Local-first address book backed by Markdown"
  homepage "https://github.com/openclaw/clawdex"
  version "0.2.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.1/clawdex_0.2.1_darwin_arm64.tar.gz"
      sha256 "eb046367457a5f0288a7f1d96d41c611a258991734ef485a079c6e3fc36c5d3a"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.1/clawdex_0.2.1_darwin_amd64.tar.gz"
      sha256 "ebd53458552e0ffbef52682c55a42020920b970b5bf24aa0a957f1e49c3c8029"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.1/clawdex_0.2.1_linux_arm64.tar.gz"
      sha256 "e9bc25fa223522607d5bd33581be207781a3850e89c057871b5ef3e9277a57a7"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.1/clawdex_0.2.1_linux_amd64.tar.gz"
      sha256 "d1efb3d4e9b51d81faf79df597a2373f52994bf99270778f6cc4da77926c5933"
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
