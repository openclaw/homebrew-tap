class Clawdex < Formula
  desc "Local-first address book backed by Markdown"
  homepage "https://github.com/openclaw/clawdex"
  version "0.2.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.2/clawdex_0.2.2_darwin_arm64.tar.gz"
      sha256 "2e7f216f9d0071a07885817f80d3dca5c172931b0928f353679580b05f522c1d"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.2/clawdex_0.2.2_darwin_amd64.tar.gz"
      sha256 "17f18db9e962034a2e3ce76795a732684d4a0e8427b4cbdcdb067b3b143ac03e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.2/clawdex_0.2.2_linux_arm64.tar.gz"
      sha256 "33d3d35c54303dace9e40af1c33998356ee9a44b137b9553de23a58f82a54de0"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.2/clawdex_0.2.2_linux_amd64.tar.gz"
      sha256 "35694de385a85a88e5e0ef379b62feb6ef048447d36f87c8a3f8bbf2b2de04d8"
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
