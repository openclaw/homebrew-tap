class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.3.1"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.1/gitcrawl_0.3.1_darwin_arm64.tar.gz"
      sha256 "c2fd38afe2097745ca2c34b9ba3a46649bb195b32bb7e7e07a8aa0cf599013fe"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.1/gitcrawl_0.3.1_darwin_amd64.tar.gz"
      sha256 "2cfcf8f9db0ee1ecbeaa5c0b1a548ed9cbcab1d6ae0e7069c4f67b98bdfb3d2b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.1/gitcrawl_0.3.1_linux_arm64.tar.gz"
      sha256 "69552c94a48b0612c10b72fae3d0b1e7523f1fe2bbe2c491fc9271515a429bd7"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.1/gitcrawl_0.3.1_linux_amd64.tar.gz"
      sha256 "59fe8c35524cb916f3e25f23d5de63e134472332d4eb5e59f7aeb8ee492a3582"
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
      gitcrawl stores local state under:
        ~/.config/gitcrawl/
        ~/.cache/gitcrawl/

      To use the GitHub CLI shim, symlink the same binary as gitcrawl-gh or gh
      and set GITCRAWL_GH_PATH to the real GitHub CLI.
    EOS
  end

  test do
    assert_match build.head? ? "HEAD" : version.to_s, shell_output("#{bin}/gitcrawl --version")
  end
end
