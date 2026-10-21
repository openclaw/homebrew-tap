class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.5/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.5"
  sha256 "0b937e1c23879c24cd22f530436e53661d729900f96eeba40e2275dd1b587a83"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.5/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "ff8c1092e35acc389e893a735b18d1641e886c9d18e894f6763a5c850d0bd2de"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.5/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "8615da3770e6444e14f14248e8a2ff95a03c1895e966768bbf30b457bbe99c0e"
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
