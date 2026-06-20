class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.6.2"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.2/gitcrawl_0.6.2_darwin_arm64.tar.gz"
      sha256 "b852e7b1bce4392171695f4bb22b4994fa6cdb118e372ddbea20e8699104d01a"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.2/gitcrawl_0.6.2_darwin_amd64.tar.gz"
      sha256 "769547c724176c632edd11ddfd62af0aa0c7a95d556780ffa54e77b040218f01"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.2/gitcrawl_0.6.2_linux_arm64.tar.gz"
      sha256 "f13b474a285597d491da701f082fbb6993cc40b9d1b621405721143a55089618"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.6.2/gitcrawl_0.6.2_linux_amd64.tar.gz"
      sha256 "35f9f164f620e97145e0f4e04f870a094728e4209c9548b1d751d45aff060536"
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
