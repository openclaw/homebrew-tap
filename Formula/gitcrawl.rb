class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.16.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.16.0/gitcrawl_0.16.0_darwin_arm64.tar.gz"
      sha256 "5107da88fa6927a162ff910ca80e4538712a0730148dd6fd9d9ddf9178d74413"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.16.0/gitcrawl_0.16.0_darwin_amd64.tar.gz"
      sha256 "e6e3e724b611707b577ca1bda136b2d17786c2f5253bb1442d741556c2e9b067"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.16.0/gitcrawl_0.16.0_linux_arm64.tar.gz"
      sha256 "e873b0eb211c6394be1bf8e26b8d245e42c57cc30a0cbaaf9b45e7b1ac18ff8f"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.16.0/gitcrawl_0.16.0_linux_amd64.tar.gz"
      sha256 "3de6a82666c6295502e16e0967874bfb37b6dec013d79d5e60f74752565fd46b"
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
