class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.4.1"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.1/gitcrawl_0.4.1_darwin_arm64.tar.gz"
      sha256 "9caf99ad765931ce593fc171ddaee0e7ce6637fc548c8de201f9c1ec1963b1a1"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.1/gitcrawl_0.4.1_darwin_amd64.tar.gz"
      sha256 "aefa98c177cbe7c95f4425d7b3b44e17ee9050e2cbe6f78f5b8deb17282e5d74"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.1/gitcrawl_0.4.1_linux_arm64.tar.gz"
      sha256 "041b6cdada59779a473787502e4c0e4dd696f0e2a3b8bd4d00976bfb822c5df9"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.1/gitcrawl_0.4.1_linux_amd64.tar.gz"
      sha256 "443247e736046667a21f4673e459e6b594c4042535161a26214421f66512485e"
    end
  end

  depends_on "go" => :build if build.head?

  def install
    if build.head?
      ldflags = "-s -w -X github.com/openclaw/gitcrawl/internal/cli.version=#{version}"
      system "go", "build", *std_go_args(output: bin/"gitcrawl", ldflags: ldflags), "./cmd/gitcrawl"
    else
      bin.install "gitcrawl"
    end
  end

  def caveats
    <<~EOS
      gitcrawl stores local state under:
        ~/.config/gitcrawl/
        ~/.cache/gitcrawl/

      To use the GitHub CLI shim, symlink the same binary as gitcrawl-gh or gh
      and set GITCRAWL_GH_PATH to the real GitHub CLI.
    EOS
  end

  test do
    assert_match build.head? ? "HEAD" : version.to_s, shell_output("#{bin}/gitcrawl --version")
  end
end
