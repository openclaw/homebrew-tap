class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.19.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.19.0/gitcrawl_0.19.0_darwin_arm64.tar.gz"
      sha256 "940af263a7c596600f7bfc176ab1e20b6b50163c8d83b380317038dec8c5910a"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.19.0/gitcrawl_0.19.0_darwin_amd64.tar.gz"
      sha256 "d01df9398a0a7a385e115b9e583a312eb590c038dfe7c8deada5ad61c9d0ea23"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.19.0/gitcrawl_0.19.0_linux_arm64.tar.gz"
      sha256 "3e810c3d9f01888d0c3f995b1e16650d367563441fc61bfb4ff8dd6583116b93"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.19.0/gitcrawl_0.19.0_linux_amd64.tar.gz"
      sha256 "b86b1a8a68458ea697b1a3f2eb669ca16c5fd2b895e1db10f7122de8c0fbf73a"
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
