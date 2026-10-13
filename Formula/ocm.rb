class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.1/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.1"
  sha256 "5fe16f6ae546a92f05b51bf1118302787984ee58e707ff2e44b4d4bc31f142a9"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.1/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "f5047f3b5a4612bf3c3069ec090ce705c8527262fbd6f6ff239c7f1b8ed0d01a"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.1/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "c0fd32059e71860710e68876e6049ee71c1ded2855ba678d8b990f08d8cc7b35"
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
