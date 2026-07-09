class Gitcrawl < Formula
  desc "Local GitHub issue and PR archive with gh-compatible caching"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.7.1"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.7.1/gitcrawl_0.7.1_darwin_arm64.tar.gz"
      sha256 "1a5cdd88178030adedd55a22d99d556c23eae22fbbe29fe8c7d0359df87cfef3"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.7.1/gitcrawl_0.7.1_darwin_amd64.tar.gz"
      sha256 "43c7303efa2bb08e629af3b5bb15c698e8d58cb52c2ea1636c188aa1b4e5dc33"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.7.1/gitcrawl_0.7.1_linux_arm64.tar.gz"
      sha256 "8e943fdf3d1ac5a452208daf32147d35aebac7501f4d0f7aa17b78e4b41659b7"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.7.1/gitcrawl_0.7.1_linux_amd64.tar.gz"
      sha256 "55b340c1608c2055f63c5d37122edd79ae190cd7ac7eefc40ef1bfa3a59f6d1e"
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
