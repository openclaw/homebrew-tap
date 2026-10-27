class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.3.7/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.3.7"
  sha256 "dc9cfe0914eb3e4f310d068f9eb4fdf02444d0550df6f6bebb85c24c9b7129fd"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.7/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "318d03259dc53cd0859ccf1ad5229d3b31d54d53dee992d6451b6f68cd6f762d"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.3.7/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "743bec0124312c714f5eaf461ca28f982c0d5c83a938030e7e25d6891350458e"
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
