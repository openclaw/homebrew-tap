class Clawscan < Formula
  desc "Agent-skill security scanner harness for ClawHub"
  homepage "https://github.com/openclaw/clawscan"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.3.0/clawscan_v0.3.0_darwin_arm64.tar.gz"
      sha256 "07cce5ac66d9b9d8a772fa23cf08b937855fb08f2c15a764cb1136e7581bb9cd"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.3.0/clawscan_v0.3.0_darwin_amd64.tar.gz"
      sha256 "020ea8508fc9d4a6f5e73519493dab919661c0b3501b165cc48ed40ec41784dd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.3.0/clawscan_v0.3.0_linux_arm64.tar.gz"
      sha256 "8cf482a3c636a6268b47b7ede6b6f857edb7b2a5dd326af7fc2291b00f02635f"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.3.0/clawscan_v0.3.0_linux_amd64.tar.gz"
      sha256 "c0f12b92623b72e43add86ebbac6ae70a027411bfba6d337c25e2334e2415c3f"
    end
  end

  def install
    bin.install "clawscan"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawscan --version")
  end
end
