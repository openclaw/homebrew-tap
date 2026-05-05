class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.2.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_darwin_arm64.tar.gz"
      sha256 "5ee6f4d2625ae46bf7f2cbc5c70479eb25391ff66442192b3341dfe0bec1a90b"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_darwin_amd64.tar.gz"
      sha256 "6c41f847a92e76f8bef7ea3abca21d2717953a838251cd18733e2a0b4fa5cd2d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_linux_arm64.tar.gz"
      sha256 "2212f2a4278241c103fc315c6a3faa4316bc2c9e26ca84a8314cb1d3c628ed66"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v#{version}/gitcrawl_#{version}_linux_amd64.tar.gz"
      sha256 "e5c0b2e44a67492c47817aa3ae2ee33749e6d6fc6d89c4eccdae5b1a6da6a53f"
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
