class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.17.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.17.0/gitcrawl_0.17.0_darwin_arm64.tar.gz"
      sha256 "56e89d051786b24bf9d7491d9dee7542ca246806585e206fcec9add763b74a7a"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.17.0/gitcrawl_0.17.0_darwin_amd64.tar.gz"
      sha256 "12f61c9e50d9618704aa4f747f50b31ae0fea82602dc4110cb2326c487bddbea"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.17.0/gitcrawl_0.17.0_linux_arm64.tar.gz"
      sha256 "ec354646e956ac881172cdb34f49de77ec60640874d4efde66dd1621cdcd39c7"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.17.0/gitcrawl_0.17.0_linux_amd64.tar.gz"
      sha256 "9b8d748a56477db029fc066d6460c616ba04eb0474f9d7ea09729b2206f1b1a9"
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
