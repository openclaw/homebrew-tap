class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.20.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.20.0/gitcrawl_0.20.0_darwin_arm64.tar.gz"
      sha256 "22eb2993f726da0b482fa7fef8f24998c18c818da4aae28d39313eb3d25f0672"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.20.0/gitcrawl_0.20.0_darwin_amd64.tar.gz"
      sha256 "65a92b04c8fab63feaee2361f2c503b19a96990255e92216a84fc74bd1c2c495"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.20.0/gitcrawl_0.20.0_linux_arm64.tar.gz"
      sha256 "3e5c850de8692dcfb5f4b6cb16090b9467d1171c6d59497be9fb7762f90dcf3c"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.20.0/gitcrawl_0.20.0_linux_amd64.tar.gz"
      sha256 "f9d0b3fe60e2a5eafb3e43ef8b365b5566208449fed1f3b6e01660f6b36f85c1"
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
      gitcrawl fresh defaults:
      macOS:
        ~/Library/Application Support/gitcrawl/ (config, database, vectors, logs)
        ~/Library/Caches/gitcrawl/ (cache)
      Linux:
        ${XDG_CONFIG_HOME:-~/.config}/gitcrawl/ (config)
        ${XDG_DATA_HOME:-~/.local/share}/gitcrawl/ (database, vectors)
        ${XDG_CACHE_HOME:-~/.cache}/gitcrawl/ (cache)
        ${XDG_STATE_HOME:-~/.local/state}/gitcrawl/ (logs)

      Absolute XDG overrides are honored on macOS too. Existing legacy paths
      may still be reused; explicit or configured paths can differ.
      See https://gitcrawl.sh/configuration/ for details.
      Run gitcrawl doctor --json for active config and database paths.

      Gitcrawl's gh compatibility shim has moved to Octopool.
      Keep your existing gh/Octopool setup; do not symlink Gitcrawl as gh.
      See https://gitcrawl.sh/gh-shim/ for migration details.
    EOS
  end

  test do
    assert_match build.head? ? "HEAD" : version.to_s, shell_output("#{bin}/gitcrawl --version")
  end
end
