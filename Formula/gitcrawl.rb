class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.7.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.7.0/gitcrawl_0.7.0_darwin_arm64.tar.gz"
      sha256 "c0af5281a16745a26ddff79eb1c57bf313d8a99e38fb6e0b3073bf9291c4e7b5"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.7.0/gitcrawl_0.7.0_darwin_amd64.tar.gz"
      sha256 "85cb758ac7c20ff2a3129ea8ac35ba65b5f4a02b84a5d11aebad949c918210b6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.7.0/gitcrawl_0.7.0_linux_arm64.tar.gz"
      sha256 "775333261b43d0bf49980700a1ade5285397208e5f9decd6b22324e0ba46de5d"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.7.0/gitcrawl_0.7.0_linux_amd64.tar.gz"
      sha256 "45b21cd31d9b027c44232c3c58fd6a23e8411d14b41fc8a7b99b814943c04864"
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
