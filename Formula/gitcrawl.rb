class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.6.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.0/gitcrawl_0.6.0_darwin_arm64.tar.gz"
      sha256 "b50467a299fbdb364ed5b46c8d122806e444a212d67f8d94152b956b6de4ff1a"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.0/gitcrawl_0.6.0_darwin_amd64.tar.gz"
      sha256 "3c6560c5618e4da5e6279c36e13d6a27fa540009c018f5d6f0b7aed68638c278"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.0/gitcrawl_0.6.0_linux_arm64.tar.gz"
      sha256 "6de0070425a4c85461d0e8a5fb590bd7359828fe0503883730b20433579a0bb1"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.0/gitcrawl_0.6.0_linux_amd64.tar.gz"
      sha256 "ffaaae123bf14d5203a98bfd3dd56138451ffe7907c4546e58729e60f4328c30"
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
