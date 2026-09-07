class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  version "0.2.40"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.40/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "9ac67161b3345e3a85e5ce0a7412cba304c9aa30cae0580e34d894b307f7ad9c"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.40/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "97772432e8a4a379d96b439faa041bcdca1098f8015222186d6c34fbb06e0de3"
    end
  end

  on_linux do
    depends_on arch: :x86_64

    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.40/ocm-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "d6236c33040af859ff79aac09fbf5f00098e7bda09b009d26bf7360d5eb82e12"
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
