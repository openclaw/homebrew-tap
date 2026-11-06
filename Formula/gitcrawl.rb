class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.18.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.18.0/gitcrawl_0.18.0_darwin_arm64.tar.gz"
      sha256 "698f17cba821e7d07beda48ce6a474d91d1e8b3d85ea9d330aefd53598ab68bb"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.18.0/gitcrawl_0.18.0_darwin_amd64.tar.gz"
      sha256 "9b315eed7032913908e991ad6195eb0438d4a39c4f7439163263e141a2f82d34"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.18.0/gitcrawl_0.18.0_linux_arm64.tar.gz"
      sha256 "a8ac06bff11be5e2f468db5ae5cae27da15c706e181af89f21e3b2d8e2a5be80"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.18.0/gitcrawl_0.18.0_linux_amd64.tar.gz"
      sha256 "64597d7215f997bb754af025362ab655dff716bd4cbbd9ee04ceaf9423c0af01"
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
