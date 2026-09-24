class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.12.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.12.0/gitcrawl_0.12.0_darwin_arm64.tar.gz"
      sha256 "81f3c6925f9a22ab9763088b21dfc41344bbe41e8fd7b82234cd219dc11aa440"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.12.0/gitcrawl_0.12.0_darwin_amd64.tar.gz"
      sha256 "f49fb0882c4e0ef245095953f308ccf94bc94fbb5e8dcbea5c77843d97cccf49"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.12.0/gitcrawl_0.12.0_linux_arm64.tar.gz"
      sha256 "9ed0aceed06925a23ff9489ae7474138db4f947ea41f6496851e9445a5aae590"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.12.0/gitcrawl_0.12.0_linux_amd64.tar.gz"
      sha256 "1d1fa760d87406f51de516e541c49eae6c3d98d71f7f2d26081d110318eaf22c"
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
