class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.15.2"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.2/gitcrawl_0.15.2_darwin_arm64.tar.gz"
      sha256 "8b28a4251c83406c36c287cb394e99ad5a1ce1c53825bc53ab796f63763ebf0b"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.2/gitcrawl_0.15.2_darwin_amd64.tar.gz"
      sha256 "7b57e8b30a3017fbdadc229f486f6b50ff83622e8382497661940c47a452991f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.2/gitcrawl_0.15.2_linux_arm64.tar.gz"
      sha256 "824be598079350e9879e6b8182826326c8fea52070d6df66e487cc514b3ba1c9"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.15.2/gitcrawl_0.15.2_linux_amd64.tar.gz"
      sha256 "cc89e9ede23f9d7c2cf83451bc1a0c438a42c6c8d6abf865a3caf6f044951d22"
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
