class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.15.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.0/gitcrawl_0.15.0_darwin_arm64.tar.gz"
      sha256 "cf08a564146725993d286b65e436aa6f89fd708c1a17d9aa10ba84ae2c2e13a0"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.0/gitcrawl_0.15.0_darwin_amd64.tar.gz"
      sha256 "b00c20781d56472abb9fdd7762981444c7c379ad5e58aa26ff5e363e78026dda"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.0/gitcrawl_0.15.0_linux_arm64.tar.gz"
      sha256 "63ff95a7f84d42f983c383e59f6882799fe018dfd5e1f5d1702379f9c2d73b3c"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.0/gitcrawl_0.15.0_linux_amd64.tar.gz"
      sha256 "abdab92fbfd1bc407a798b7dabc37fe67da3c42966f63a65e70193fac808b495"
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
