class Gitcrawl < Formula
  desc "Local-first GitHub issue and pull request crawler for maintainer triage"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.1.2"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.2/gitcrawl_0.1.2_darwin_arm64.tar.gz"
      sha256 "5346f86659308f8a5bb55eee3cb9741e983b55512a82b75f9d5a1d398a9065e7"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.2/gitcrawl_0.1.2_darwin_amd64.tar.gz"
      sha256 "b1d48d630d2d3aeb06a1f34aa0e00fa7b7e66d4a19aab5ae81efe266b95c7a7b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.2/gitcrawl_0.1.2_linux_arm64.tar.gz"
      sha256 "70e770c19b708f31d4ed22e4243367eaa02ec67c34fdf3e92a5a403656a3734a"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.2/gitcrawl_0.1.2_linux_amd64.tar.gz"
      sha256 "dbcaa79ae864ca205cc7b204930576b77f1d60e7d8e7a56bb0eb14360b2963d1"
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

  test do
    assert_match build.head? ? "HEAD" : version.to_s, shell_output("#{bin}/gitcrawl --version")
  end
end
