class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.8.1"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.1/gitcrawl_0.8.1_darwin_arm64.tar.gz"
      sha256 "794732d9bbed6400a16ae47d812aa960a7725bae5da9adb68f9e43d51badfb09"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.1/gitcrawl_0.8.1_darwin_amd64.tar.gz"
      sha256 "384f7157f17a2a617222273d88853ddc3d80324e9fa256b74b6ea14502acadcd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.1/gitcrawl_0.8.1_linux_arm64.tar.gz"
      sha256 "f174b72aa37a3b52e2de1857915122ec45c3a4bf57a7d7d13e5937df314841dd"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.1/gitcrawl_0.8.1_linux_amd64.tar.gz"
      sha256 "3cf142d3ea1194c7edd80c52a8121d8a0bac8a8998618f1a4e2a1bb7f9afdd5e"
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
