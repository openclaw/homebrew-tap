class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.2.44/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.2.44"
  sha256 "73c9ae077986bbb76e79cf1ded9ed285547124c045c91d08e4330552b7e805b0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.44/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "5af02cca61951f3bad795e435871a337645cf95c247ac51eef4899fe066e2011"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.44/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "86c8056dd2ca7a055033a88a4e7ec7e38e5e14da6b8205567bdf5b6f89d9c86b"
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
