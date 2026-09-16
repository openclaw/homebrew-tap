class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.2.47/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.2.47"
  sha256 "05e0bb598fe391c75fe7668e159d7eb09168b4298b5d8d0999786e79e97d0642"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.47/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "53a1fe66324624a8fd5e81adb16eae656a8e1c627c6bc3b242bca4cbbe0a583e"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.47/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "8fa6ff27dfb40f2ef7acccb7967f27c458c794ad4deb32f04a7e3ecfc2c53651"
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
