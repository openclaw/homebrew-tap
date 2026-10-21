class Clawscan < Formula
  desc "Agent-skill security scanner harness for ClawHub"
  homepage "https://github.com/openclaw/clawscan"
  version "0.2.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.2.1/clawscan_v0.2.1_darwin_arm64.tar.gz"
      sha256 "65472bba6e2abe309e269a97594660311d769574e0083a8c4458cb1ed859f9a0"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.2.1/clawscan_v0.2.1_darwin_amd64.tar.gz"
      sha256 "a9760514aef33577dee2c33127dc9ded7ee2f2442ac6dc6a8bd1e277e00e1554"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.2.1/clawscan_v0.2.1_linux_arm64.tar.gz"
      sha256 "715bc55d54aff4eb84e95a08b6e70dd3d9a9989d2c600fb362ed3f90cf260447"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.2.1/clawscan_v0.2.1_linux_amd64.tar.gz"
      sha256 "499fcb2a623b048889615d23f4b786289f4d45e1916a9225ba93f29fd3d5f6c7"
    end
  end

  def install
    bin.install "clawscan"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawscan --version")
  end
end
