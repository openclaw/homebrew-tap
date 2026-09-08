class Ocm < Formula
  desc "Manage isolated OpenClaw environments, runtimes, and services"
  homepage "https://github.com/openclaw/ocm"
  url "https://github.com/openclaw/ocm/releases/download/v0.2.42/ocm-x86_64-unknown-linux-gnu.tar.gz"
  version "0.2.42"
  sha256 "56595385043e326b38be3d2701d46fe33f857515072314e7904242e1755fb47a"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.42/ocm-aarch64-apple-darwin.tar.gz"
      sha256 "c9c05605252b6fb35648613e21cf7d8d01002b9f0461c411ac952d24b0f32353"
    end
    on_intel do
      url "https://github.com/openclaw/ocm/releases/download/v0.2.42/ocm-x86_64-apple-darwin.tar.gz"
      sha256 "74f274929b6fd2356ac5b412ce5ab0662d3baca7e9e8090b5dae3c453b0eec96"
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
