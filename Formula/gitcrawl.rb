class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.15.1"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.1/gitcrawl_0.15.1_darwin_arm64.tar.gz"
      sha256 "869fff467ce9eb5cc33260e3b02f08aa8efea3a8fe042c5e4acec3472fd1a06f"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.1/gitcrawl_0.15.1_darwin_amd64.tar.gz"
      sha256 "418609538e21226bb54725f0933c5e873a640c5763fbf74c49deb68860a3c697"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.1/gitcrawl_0.15.1_linux_arm64.tar.gz"
      sha256 "419f47cbd2d46e9154b18ced91d65378da13a2614e286b0b707e714169d89495"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.1/gitcrawl_0.15.1_linux_amd64.tar.gz"
      sha256 "c5f9dcc9678d27b3a9e5874c43c7c2fc539496791eab20a6170859c491991725"
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
