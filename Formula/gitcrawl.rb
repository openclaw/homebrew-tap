class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.8.3"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_darwin_arm64.tar.gz"
      sha256 "1a493b0816cc503de62d75259a4630d9fa6778444c441ec3fb01eb0a76026b9c"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_darwin_amd64.tar.gz"
      sha256 "603449d65ee453828a77080db6359f4cbda531e915b60302f1495bf236ea9c99"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_linux_arm64.tar.gz"
      sha256 "99b36455561f91b14bf699a6e932b43dff1e55bbfd94b00b097d4962b71fa224"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_linux_amd64.tar.gz"
      sha256 "9449650f5e1a674253a7c5c1ec8a55fc9c87e7bae702e33f6fef133c56d7888e"
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
