class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.3.2"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.2/gitcrawl_0.3.2_darwin_arm64.tar.gz"
      sha256 "faf280c251a796c905f8c7502b1e7711a2177178fe9fcd13e8df20e362413ff7"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.2/gitcrawl_0.3.2_darwin_amd64.tar.gz"
      sha256 "05825e6cabe119a23ebe6c05bd6803a3df13386d0937b443519d9e13fbd32155"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.2/gitcrawl_0.3.2_linux_arm64.tar.gz"
      sha256 "5f87ae837e12233f17f32f04fa71363d13687a5a61dc84584c7f07b8da0d817d"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.2/gitcrawl_0.3.2_linux_amd64.tar.gz"
      sha256 "730ead53898844068beb6a098eecf25c84da7012e26ddaef0ae6a27feaa14264"
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
