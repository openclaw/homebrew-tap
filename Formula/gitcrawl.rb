class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.8.2"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.2/gitcrawl_0.8.2_darwin_arm64.tar.gz"
      sha256 "52d8ab476d4d528908b3a62a1d92020686fb63ae0bfcbf4dcbb3d6b9bc6f4c52"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.2/gitcrawl_0.8.2_darwin_amd64.tar.gz"
      sha256 "2612343a43e8ed137adef903c91ba487b52ed93a7242b53531efc2e9b75c2916"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.2/gitcrawl_0.8.2_linux_arm64.tar.gz"
      sha256 "63a885c88b198c91d2097604379cd476ad65e9953351e4272285354264af9b18"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.8.2/gitcrawl_0.8.2_linux_amd64.tar.gz"
      sha256 "e95a7b9e38a3ad5e483877c327e7077b2ed61e9eac9af6e9f2846de16a0239b1"
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
