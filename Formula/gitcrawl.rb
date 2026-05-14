class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.3.4"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.4/gitcrawl_0.3.4_darwin_arm64.tar.gz"
      sha256 "e0d334ce5377ab176cc4f0c180a3c3a80d77bd45fc6c2be3214ee8df8374a4ad"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.4/gitcrawl_0.3.4_darwin_amd64.tar.gz"
      sha256 "673737d357af370ffe2fe89dce62d965918c6d2f0bb690fb450783e9896223f0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.4/gitcrawl_0.3.4_linux_arm64.tar.gz"
      sha256 "90a5a1588b84b914208ad0d2ca067496b0ec6f7a1e35a378dc3a9e2bc3038650"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.3.4/gitcrawl_0.3.4_linux_amd64.tar.gz"
      sha256 "866eb34ed541b11d4ed7fc1df4ba02c7e1576955c8076b3899dc843eaf8dc7b1"
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
