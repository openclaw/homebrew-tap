class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.6.1"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.1/gitcrawl_0.6.1_darwin_arm64.tar.gz"
      sha256 "21291eba60bd79cdb78251a6ed2fb11eeaa41d5b82a05d6d52dec9791ae2cf68"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.1/gitcrawl_0.6.1_darwin_amd64.tar.gz"
      sha256 "3270ccae53089bed48a011ea81c612ba827565f6f802541305ee03782e608ebc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.1/gitcrawl_0.6.1_linux_arm64.tar.gz"
      sha256 "416eb7ae5558a74996b99d30139b6e6265ceff0a12643148df700d58e4d1fb05"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.1/gitcrawl_0.6.1_linux_amd64.tar.gz"
      sha256 "e4430c97efcc9f257729d2d49451563cfa2aa42b9d27c3660225fa1a2def7a86"
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
