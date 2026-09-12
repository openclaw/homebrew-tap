class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.2.46/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.2.46"
  sha256 "8981ec7937532f324c477b30c239dcd7f5ed60c32fe5dedde5fccd9d4ffbd739"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.46/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "ff25d72ad60b04937b0646b8017b128e03b7ba2f7534a1bd9cd2a5bd3aabf5d4"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.46/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "04d8e3aae3abf3b96dfeb5866c22d530fb9a25e70217e56c9c8c5b2eef4408f3"
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
