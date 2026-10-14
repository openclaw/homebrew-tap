class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.2/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.2"
  sha256 "2eb204bc6896de940bf629133bf770383558828e5302c21f1ac68fc3206a0517"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.2/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "40ec7c7e2bae7548e1c750624059e98f0f87759613999957f9744af740f01cc3"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.2/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "a0876d9c22d907de5ac07a2a5d6788848fd49ad4ea5b42e1c9ad501909dd00e3"
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
