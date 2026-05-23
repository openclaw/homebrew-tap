class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.4.4"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.4/gitcrawl_0.4.4_darwin_arm64.tar.gz"
      sha256 "8e9a243317d2eebfe66c9695ec56b80b24a93cbd46fc5d1f41de29f3dfd41775"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.4/gitcrawl_0.4.4_darwin_amd64.tar.gz"
      sha256 "c26a48046885e0f231db41dba2d1e8446ecfd32e63243dd7e588aff80b184aa8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.4/gitcrawl_0.4.4_linux_arm64.tar.gz"
      sha256 "b48bd6fa739a156bdbb1db3e949a5857d3b063b37d96e1163898aaac81ede503"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.4.4/gitcrawl_0.4.4_linux_amd64.tar.gz"
      sha256 "ba9753fc3024eaaf65ca1245b34eb08e64a18bea0e19f1603ebf47480ae4b83a"
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
