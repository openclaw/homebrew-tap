class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.3.3"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.3/gitcrawl_0.3.3_darwin_arm64.tar.gz"
      sha256 "483ed5243083f7289a97fa8d23bb3a70ddf6e255ced4fcdff99d3c9ada2c1647"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.3/gitcrawl_0.3.3_darwin_amd64.tar.gz"
      sha256 "a7da44d9043e1e301c6f0fa288968229cbf0ac90c7cc4e392ecaac682506f65f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.3/gitcrawl_0.3.3_linux_arm64.tar.gz"
      sha256 "9579761e0af7b393695f7ffa660b6a649ac8a6d8f88aea7ffb50084698c71e7d"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.3/gitcrawl_0.3.3_linux_amd64.tar.gz"
      sha256 "1d35c7669e8f898697a5efde3f65e34e17a5e7c6134bb9e6bfb269857144471f"
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
