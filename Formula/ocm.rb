class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.6/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.6"
  sha256 "29e32a50d6255de21793851d078948b171db925ba564f7af17a3b23c219558f1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.6/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "29deb0bebd56bc4948507653a0c61a210ab37eb4cf77943dfd8f3881bf5d3731"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.6/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "0e8088c2c48e59317a047c885da3d8bf07a440f2acfba9ac2f0b5ae8594e6105"
    end
  end

  on_linux do
    depends_on arch: :x86_64
  end

  skip_clean "bin/ocm"

  def install
    bin.install "ocm"
  end

  def caveats
    <<~EOS
      Update this Homebrew installation with:
        brew upgrade openclaw/tap/ocm
      Do not run `ocm self update` on this installation.
    EOS
  end

  test do
    assert_equal "#{version}\n", shell_output("#{bin}/ocm --version")
    assert_match "ocm", shell_output("#{bin}/ocm --help")
    if OS.mac?
      system "/usr/bin/codesign", "--verify", "--strict", bin/"ocm"
      assert_match "anchor apple generic", shell_output("/usr/bin/codesign -d -r- #{bin}/ocm 2>&1")
    end
  end
end
