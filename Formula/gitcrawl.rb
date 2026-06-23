class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.6.4"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.4/gitcrawl_0.6.4_darwin_arm64.tar.gz"
      sha256 "5f50bea94be26feb5aab276af04aec7b3cefa504af82dec23b53bb78d655988f"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.4/gitcrawl_0.6.4_darwin_amd64.tar.gz"
      sha256 "17d9ed4cf7b838c2ba31ddb920942fd46e6145fa709bea00e375d405f1533e8c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.4/gitcrawl_0.6.4_linux_arm64.tar.gz"
      sha256 "ac74712821b6441a0844e6f30fc86380b8c13f73eb3a6f82e68c188e9742e31b"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.4/gitcrawl_0.6.4_linux_amd64.tar.gz"
      sha256 "9ec85a41ca8491985974290fd5b171ab35e66da3c838f98f662747021b9eecb7"
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
