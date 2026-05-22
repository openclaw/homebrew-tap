class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.4.3"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.3/gitcrawl_0.4.3_darwin_arm64.tar.gz"
      sha256 "1b041311021d8abebc19630473bfe9c06670422eb847149298becd275b450847"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.3/gitcrawl_0.4.3_darwin_amd64.tar.gz"
      sha256 "8a97ec0f4e954c7aa7b792d0dcfd7c025df271fa27f595317e76eb4e46aedb40"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.3/gitcrawl_0.4.3_linux_arm64.tar.gz"
      sha256 "938abb76653b5ac704eb0b5b8ed9fcb546a24a8c06cb07136fbfc6a33739fb66"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.3/gitcrawl_0.4.3_linux_amd64.tar.gz"
      sha256 "c75b6099e5b583bb3fb8b77c4c17df7e73cc9c07889c1943e5ab3e786b1e2165"
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
