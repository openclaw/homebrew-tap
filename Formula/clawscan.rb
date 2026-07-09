class Clawscan < Formula
  desc "Agent-skill security scanner harness for ClawHub"
  homepage "https://github.com/openclaw/clawscan"
  version "0.1.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v#{version}/clawscan_v0.1.2_darwin_arm64.tar.gz"
      sha256 "ece4716234e65c5e4c4a98c7b23677b8c5bf8edffc07e9607dd9bbda97578240"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v#{version}/clawscan_v0.1.2_darwin_amd64.tar.gz"
      sha256 "70c0a37a9013e9dd00df928233a0544d75f1694b2e4562e92a220de66f3441e9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v#{version}/clawscan_v0.1.2_linux_arm64.tar.gz"
      sha256 "f15281ad4563938875b7e6f32a9c9d7dc3302555f7b5d352508745d956b217a8"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v#{version}/clawscan_v0.1.2_linux_amd64.tar.gz"
      sha256 "243b54e8d0083f306aeaaa8feb0256e447b0ed78eb7230f59e123a1c7553338d"
    end
  end

  def install
    bin.install "clawscan"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawscan --version")
  end
end
