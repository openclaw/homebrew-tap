class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.4.5"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.5/gitcrawl_0.4.5_darwin_arm64.tar.gz"
      sha256 "b69f2323b073193200e600428807c4859cae5fe9f388d43e7cca095c7a2fcf2f"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.5/gitcrawl_0.4.5_darwin_amd64.tar.gz"
      sha256 "ecdf4ec21b8bbbc1ebbcb84b2ab47ed860ee4f0f94e160c618bf3fc2f9c4460a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.5/gitcrawl_0.4.5_linux_arm64.tar.gz"
      sha256 "e64655c81b547939a1d5e567ee1284be915b56e3ad67d3c4799661b2121a9a92"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.5/gitcrawl_0.4.5_linux_amd64.tar.gz"
      sha256 "97e0bcde47279b7648c5106aab3821c017799940ffb6da0e69c5302ed4b5d269"
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
