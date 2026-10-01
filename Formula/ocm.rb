class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.2.48/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.2.48"
  sha256 "d0bdb49d69fa8bf3c3487ff04f4be82126828876f81690afdc002c427e22c1ac"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.48/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "6dcad3d8e388e5093f9db05cacdbc809cd44f6105fc50ee012d43cf5caf4cb58"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.48/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "71b111a0d0aa9aaa95ace6afba16fed05b3cf46e04d963742b33fcd0076b9ca4"
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
