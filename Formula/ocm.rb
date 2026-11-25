class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.10/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.10"
  sha256 "78700755a592aeaf74915ad31addff60fd4a606d767d38b7ddc90411444c3479"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.10/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "9713c660f523a772033e6574a9b5823ea76cf4845b9838d96964f0058cf19034"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.10/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "adcd75c411f49b7988b5df7e54fb6d29a80efb481ef9a220af9ed513257c8b3a"
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
