class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.9/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.9"
  sha256 "362ea839c7b87af15057e047699ba62f71fcfb9707078248b5cd0fb9bf3f5b38"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.9/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "f0caf751d4a62fad1e6d6ae7db049ffaf6ad8e5ae6fc4c3b6165907bf2a02c09"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.9/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "6c27f78d37c63261d1d8bda3a56bf8d7d7f2ef170d8931d8cc08760fcd9cd7c1"
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
