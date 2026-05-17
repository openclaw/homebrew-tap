class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.4.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.0/gitcrawl_0.4.0_darwin_arm64.tar.gz"
      sha256 "979f595e8e91fa7bcb427189c8fa3a7409a1363e221639bb1495223ad88fe5cf"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.0/gitcrawl_0.4.0_darwin_amd64.tar.gz"
      sha256 "c6225bb9e2102a51833ad82019b5b535296e31a77ac2f3d56f61c1df68b48f0f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.0/gitcrawl_0.4.0_linux_arm64.tar.gz"
      sha256 "bb958a84e0f1f22395952fc1030eb6b27633c78b7cbced4d17d2250670dfd5f3"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.0/gitcrawl_0.4.0_linux_amd64.tar.gz"
      sha256 "2f3afa7cae5f87f7b518737ce6594e21e72b922616ed34ef2dbf33118d945fc7"
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
