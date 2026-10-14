class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.3/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.3"
  sha256 "541171a3beca7c564dd3a071cfd756d49d611b0f11018784764a622b22a34fa4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.3/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "b75693321df80d43023788b11c78ee69361becc868127f08d61ac8c6e7740f5a"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.3/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "467c63ee07049a5fd62ef2b5dae2e2c726e77292e2e1221463aa8fbc7380be10"
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
