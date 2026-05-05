class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.2.1"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_darwin_arm64.tar.gz"
      sha256 "597501fb036de66bbb3948e547b71a30788168a2cc25b75f275f58d13bd583e3"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_darwin_amd64.tar.gz"
      sha256 "94e7cd5c1ed7a7ff441f7eecac3b03c765cb7c33b7a45e9b7118dea601fe44cb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_linux_arm64.tar.gz"
      sha256 "2f10615ebec83055d5efb4c01e2e466416eca554b7f9b821a08f1386ff592aef"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_linux_amd64.tar.gz"
      sha256 "f0d234ad12b0323dc61352b4d11ddedd6b66e9bed8c53e1a67640242324dfd4d"
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
