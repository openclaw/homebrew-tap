class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.13.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.13.0/gitcrawl_0.13.0_darwin_arm64.tar.gz"
      sha256 "2e83ae97988ee74940bf3f4860e47f4c8b4240a6248c731955c608ea27e6eacd"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.13.0/gitcrawl_0.13.0_darwin_amd64.tar.gz"
      sha256 "78404b3c1de93c8b1e9f5aef4e4c984931438c1e1b3e2e3508a291859e5dc154"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.13.0/gitcrawl_0.13.0_linux_arm64.tar.gz"
      sha256 "65dfa9055cc42573fb6d8e50e64122a040ba899a13ff988eaecbb3e2f7852905"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.13.0/gitcrawl_0.13.0_linux_amd64.tar.gz"
      sha256 "8f3d9f27ba883ca62222991caa95a908828c4186619c85fdff428ff76325d265"
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
