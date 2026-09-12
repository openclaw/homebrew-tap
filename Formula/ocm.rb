class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.2.45/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.2.45"
  sha256 "5ed55e0c4b54a561e09b8204b1ae97a6c743b13f35e383611e84729561de924e"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.45/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "bee47c66dc0f4710f0c9106fc2bfc3ed025c758fa580c74b86be674068dc188b"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.45/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "05d6087c93c6c10877ccd0f6fcf756f2cd3b982c2254a994a3bff1c492c7251b"
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
