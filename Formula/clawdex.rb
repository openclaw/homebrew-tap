class Clawdex < Formula
  desc "Local-first address book backed by Markdown"
  homepage "https://github.com/openclaw/clawdex"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.3.0/clawdex_0.3.0_darwin_arm64.tar.gz"
      sha256 "5d5b39b2564200d7c93ec6187ee5623d514b10ff21fa43f2995e0f25f23f6507"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.3.0/clawdex_0.3.0_darwin_amd64.tar.gz"
      sha256 "3bc6a6aeddc76ac28952a44b5a06f8e77e5c96ef0b92c2c2494afe6cd21be68f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.3.0/clawdex_0.3.0_linux_arm64.tar.gz"
      sha256 "fb889603aa797c3c1c6ecd5284c52c2d1e803daf7036bed53c8b61640b37c773"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.3.0/clawdex_0.3.0_linux_amd64.tar.gz"
      sha256 "bfe6f4a70704afe5c3870f7fe4d816b2deb791dc3d0e87a4dd886818d807d483"
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
