class Clawscan < Formula
  desc "Agent-skill security scanner harness for ClawHub"
  homepage "https://github.com/openclaw/clawscan"
  version "0.1.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.1.8/clawscan_v0.1.8_darwin_arm64.tar.gz"
      sha256 "f754cb08faa963083486994bdf1bed78e276d9c833d33b424c6e50c49aafaa0d"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.1.8/clawscan_v0.1.8_darwin_amd64.tar.gz"
      sha256 "ea99867fb0b50679a57d09958c10dca5b3f3584f108696b02c07380500f6b5b2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawscan/releases/download/v0.1.8/clawscan_v0.1.8_linux_arm64.tar.gz"
      sha256 "151844c915548410341bac575a3a77eaeb09dc40b4ccfbd00f99a93cace40a3c"
    else
      url "https://github.com/openclaw/clawscan/releases/download/v0.1.8/clawscan_v0.1.8_linux_amd64.tar.gz"
      sha256 "8332479963a1629211e72d41806b3050da27a35ca7597e1012c36f8880fc7394"
    end
  end

  def install
    bin.install "clawscan"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawscan --version")
  end
end
