class Clawscan < Formula
  desc "Agent-skill security scanner harness for ClawHub"
  homepage "https://github.com/openclaw/clawscan"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.2.0/clawscan_v0.2.0_darwin_arm64.tar.gz"
      sha256 "9ef32ab2afa16ddba14189148c028e74ca6da64e4b4702da41929ed4a9baf128"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.2.0/clawscan_v0.2.0_darwin_amd64.tar.gz"
      sha256 "3b15b27b7dea2b2c48531181cd95f68bf9f908e063d18ca0b7552d94f9ace933"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.2.0/clawscan_v0.2.0_linux_arm64.tar.gz"
      sha256 "fefbaadde4e8ac3d711199acc2148238009433c6fc0e02c293c0c2c18b1b5933"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.2.0/clawscan_v0.2.0_linux_amd64.tar.gz"
      sha256 "ee8f3f970930e3e8c15c6e132b30255bd0ff07c3295e481d7cf75d95aa76f19a"
    end
  end

  def install
    bin.install "clawscan"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawscan --version")
  end
end
