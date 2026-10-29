class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.8/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.8"
  sha256 "453cea5715c62cab68749becb1ddab802dcd8507054a12901c60878536045a58"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.8/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "3d2935efb1435cf97f12baba11d9a7ed18118cd9f50d949a54cdfb6513ee3009"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.8/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "b61288475c3ba91e522031031b27a49a725daad01a43a9c8c68b5790e176e2f3"
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
