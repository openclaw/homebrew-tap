class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive, search, and clustering"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.10.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.10.0/gitcrawl_0.10.0_darwin_arm64.tar.gz"
      sha256 "26c2e0d387d4bcfcda9379feb4c105e1238e82fbc1adc11d89fd10ef4a4c720e"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.10.0/gitcrawl_0.10.0_darwin_amd64.tar.gz"
      sha256 "7066984545756b30cb3dc79c6b556b10c2f8975b0b611bd0e9b26dfeeccce517"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.10.0/gitcrawl_0.10.0_linux_arm64.tar.gz"
      sha256 "7fbb8f116dcc1066580233059168c513d324a9b6b11bc19834b3afc7de0abfed"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.10.0/gitcrawl_0.10.0_linux_amd64.tar.gz"
      sha256 "c2e9bf74ab3606810591869ec16762fb6475792a676e89ab5ea893b83754ab77"
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
