class Clawdex < Formula
  desc "Local-first address book backed by Markdown"
  homepage "https://github.com/openclaw/clawdex"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.0/clawdex_0.4.0_darwin_arm64.tar.gz"
      sha256 "59d7571091d573414e5720bb5cefbcfe3aec0b96eca26ccb8fc3665b72adc722"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.0/clawdex_0.4.0_darwin_amd64.tar.gz"
      sha256 "505bba6e97b1d088e73cba1bd3bf9a3c74727c5473558fdef3f975c7acc0695a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.0/clawdex_0.4.0_linux_arm64.tar.gz"
      sha256 "db51f1d6168a0c6a38330a82bd02597747687ebcc49e823d2a4405c7fb865592"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.0/clawdex_0.4.0_linux_amd64.tar.gz"
      sha256 "f9061566724fc8baa65aac96b86bf5fb73834394c074d702d55e2b2eb8512adc"
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
