class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.9.5"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.9.5/gitcrawl_0.9.5_darwin_arm64.tar.gz"
      sha256 "e842c68039b51b8554e495f762791750f2f0771ac693c629e858865325d03f0d"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.9.5/gitcrawl_0.9.5_darwin_amd64.tar.gz"
      sha256 "75dcf368700a318ff3116fa643fd3495cac115c13bb450490576c23ce278a6fa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.9.5/gitcrawl_0.9.5_linux_arm64.tar.gz"
      sha256 "6afbff44fbe6b9ebf3c6ff550099e069e1920ee9b0a8bad66ae294656b537be7"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.9.5/gitcrawl_0.9.5_linux_amd64.tar.gz"
      sha256 "60b8d565a9d6e38bf02a4c819e0807598d33ecb9ed6d003ebccd753ca48410af"
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
