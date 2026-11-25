class Clawscan < Formula
  desc "Agent-skill security scanner harness for ClawHub"
  homepage "https://github.com/openclaw/clawscan"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.4.0/clawscan_v0.4.0_darwin_arm64.tar.gz"
      sha256 "15a91a7733b7be061159f4745598b21d2a21c914e7acc8ef44e0517cf2440a51"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.4.0/clawscan_v0.4.0_darwin_amd64.tar.gz"
      sha256 "4bb14f8bdb7ceeea3e8923b3ceda634607378baae965892ff70d94264b388072"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.4.0/clawscan_v0.4.0_linux_arm64.tar.gz"
      sha256 "0955a8423e211c11affeb1601c3aa2e995b9e7c76533e30ef7b616ac41f07653"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.4.0/clawscan_v0.4.0_linux_amd64.tar.gz"
      sha256 "f5a9c07b6ee88366f3bec0fd89ceeb1ebcdffa1b45232d6588165fec27249393"
    end
  end

  def install
    bin.install "clawscan"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawscan --version")
  end
end
