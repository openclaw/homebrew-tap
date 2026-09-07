class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  version "0.2.41"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.41/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "99640a65ecc4d8175c76c4336b3b9b3a4c8f9877f40a4b6d9c4ce4c66330b83c"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.41/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "34b3ec80742df8fdf18290611e3ec30daba1291f0ba1c7b0ef829672036b622e"
    end
  end

  on_linux do
    depends_on arch: :x86_64

    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.41/ocm-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e57dc642d70310f8bf19096c0fc41aab0325c8fab24b9ed0c6367c60a02b6198"
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
