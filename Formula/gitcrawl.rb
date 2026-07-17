class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.8.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.0/gitcrawl_0.8.0_darwin_arm64.tar.gz"
      sha256 "8ac11b9e25473cf15f62afd42c98d11f114caf74d674c5b95bef78173c25d2ee"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.0/gitcrawl_0.8.0_darwin_amd64.tar.gz"
      sha256 "d921d3e43449f7f729a62d70e56621a95b14e6cb6333230fcb5e8b39f94c9020"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.0/gitcrawl_0.8.0_linux_arm64.tar.gz"
      sha256 "8ce3eda3f73a5fd2855991ceba152686081eafe772fae25a6341f5a620827e1e"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.0/gitcrawl_0.8.0_linux_amd64.tar.gz"
      sha256 "dba55414f0e59fec6bd29a115a7eab54a67fdd54f67bc19c38ea84a4ead0c6bd"
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
