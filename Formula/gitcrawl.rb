class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.5.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.5.0/gitcrawl_0.5.0_darwin_arm64.tar.gz"
      sha256 "84f1e835b0195f6f7a2e9970aa701fcd2642b372318bae214cbd6b674d60f0fd"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.5.0/gitcrawl_0.5.0_darwin_amd64.tar.gz"
      sha256 "260c1935a48bfd2e8b616573ea2339106896b75d3407d9725373ed6636fdc12d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.5.0/gitcrawl_0.5.0_linux_arm64.tar.gz"
      sha256 "333bac71c9b9f91dcd19c82f5e4e97922120b5e9000595439bbb80715bdc19f2"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.5.0/gitcrawl_0.5.0_linux_amd64.tar.gz"
      sha256 "66c5f0d13b3e22de4685711388293dfe573d002962746ff9d75fb5fc0576f56c"
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
