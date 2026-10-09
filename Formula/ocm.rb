class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.0/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.0"
  sha256 "50c52150e40cdc934b8ecca9973e8ec51d86f7f6441db01d5ab0c4246c08ad5a"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.0/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "826a2a77dd648fd6249cb1abeb083574531c6a0ce543ccab5fc5b030da72eb83"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.0/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "a93be20ec176652272ba8d217906292c7ddcbb995a5c72b908a82e0670025995"
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
