class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.4/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.4"
  sha256 "97c83fd301cb18b439ea3285f8266924aa46033f5617ccfecbd09ac2869dd26b"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.4/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "44099f974ff4dad8817fea2da4cc51cefa57fbaafadb903fea9cc9a2536262ff"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.4/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "b0e06804977e39ad214986a4ae67820f02bc9509d8dabb3d632334d260a9d31a"
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
