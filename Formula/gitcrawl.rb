class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.3.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.0/gitcrawl_0.3.0_darwin_arm64.tar.gz"
      sha256 "336381db2125907944035b4d15f23d9278e9c7f1a140994b1b039b026ff04d20"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.0/gitcrawl_0.3.0_darwin_amd64.tar.gz"
      sha256 "cb1188dd26b910aa4d2cc598a16e0eae45d0284a63e4bc03cc9e9eded25eb185"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.0/gitcrawl_0.3.0_linux_arm64.tar.gz"
      sha256 "dbc0adc6b1e9155243a5251cb0fd4c4a2963f6907257c2f19098ca2464f18ac1"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.0/gitcrawl_0.3.0_linux_amd64.tar.gz"
      sha256 "6669b0f01e04c0261c1b5c8e85049283f72a65b0aa24fc81f2154e0a675618f4"
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
