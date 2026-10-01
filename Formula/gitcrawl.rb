class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.14.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.14.0/gitcrawl_0.14.0_darwin_arm64.tar.gz"
      sha256 "676cf1a17e1130c302cfc636f77d23aee4fcf97cb06ccd58414e3c011f42dccc"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.14.0/gitcrawl_0.14.0_darwin_amd64.tar.gz"
      sha256 "b9d72f39919af55fde7471fb6823207badc26348a6b65ea937433b91de205aab"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.14.0/gitcrawl_0.14.0_linux_arm64.tar.gz"
      sha256 "18ff51cb46355063dbcf299d91cc2ee39051172f4102c1b1f5713f37cc1bae83"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.14.0/gitcrawl_0.14.0_linux_amd64.tar.gz"
      sha256 "efc2d3401aea255c731c814e2351c4283df50f2b68acaa89187dcc85746bdbdd"
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
