class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.2.43/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.2.43"
  sha256 "fa34c265afbc18aa6e8cc7e8b857a9b84efd42f737a49e527b093a6771e751ad"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.43/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "9a1ce8aeb5ec0aa65637d336c120e3771605fc3e0ca7dc21e2cfeb90a2adcc0c"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.43/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "8503d2e139ae43c8455b05a10e2c309528be2c332d7dc9d156c4d74e6a3ab1cb"
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
