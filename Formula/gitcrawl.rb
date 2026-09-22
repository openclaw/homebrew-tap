class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.11.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.11.0/gitcrawl_0.11.0_darwin_arm64.tar.gz"
      sha256 "fa80e1feb3d07f70405234aea40e80af4c9af7d06da60b1981d9f388081306fe"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.11.0/gitcrawl_0.11.0_darwin_amd64.tar.gz"
      sha256 "85520a630089ef4629d022d0524eca4230ebb6e780157c53cc23c58fb253aff4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.11.0/gitcrawl_0.11.0_linux_arm64.tar.gz"
      sha256 "0cf57f2dd647bbd0014173605a7af3fa4b1f3787de41dfa3f201435772551eb0"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.11.0/gitcrawl_0.11.0_linux_amd64.tar.gz"
      sha256 "d8d3fa8a8ad9b1255959ac15d685d423763ecc33d27531a25df744ccbb52e5d4"
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
