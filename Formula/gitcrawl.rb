class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.6.3"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.3/gitcrawl_0.6.3_darwin_arm64.tar.gz"
      sha256 "0371f78ed017534643307004aab2e8a0f0b5e31519290fed32bfa9bfc78e52e5"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.3/gitcrawl_0.6.3_darwin_amd64.tar.gz"
      sha256 "e88e6752527b441bc428f3cf1c34e593136827b54b28333af43e0ae8e25ae44c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.3/gitcrawl_0.6.3_linux_arm64.tar.gz"
      sha256 "52829c311683416f3693c175a00829d04b028bfbeec47666bdfa6800c35c14ec"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.3/gitcrawl_0.6.3_linux_amd64.tar.gz"
      sha256 "61962df63c2ce01380ca96c2a0192a9e28035b16969c729d1f3f81a05396aeba"
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
