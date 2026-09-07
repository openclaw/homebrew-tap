class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  version "0.2.39"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.39/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "a8c9700227bee9ed9264251512e75a4b434700cb4b2cd9a5bcac2b56fde25f39"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.39/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "6f221625ff54f62495bc61c8ab4f81e66ddecf079167a37548c1fe1a4da76034"
    end
  end

  on_linux do
    depends_on arch: :x86_64

    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.39/ocm-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e34a5e1b7f8cfab011ebb3b81fd661da2ec71e427084da756fa3bde61f5a4d9a"
    end
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
      OCM v0.2.39 does not prevent self-update from replacing a Homebrew-managed binary.
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
