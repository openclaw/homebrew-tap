class Gitcrawl < Formula
  desc "Local-first GitHub issue and pull request crawler for maintainer triage"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.1.1"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.1/gitcrawl_0.1.1_darwin_arm64.tar.gz"
      sha256 "44feb2803f08858df649588eaa220550425a4cbc9c6bacbe69e05477061519e9"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.1/gitcrawl_0.1.1_darwin_amd64.tar.gz"
      sha256 "3c2791d4090691546ee2cad8c1803854f706ec1736f59327ab736c4ed9a06d19"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.1/gitcrawl_0.1.1_linux_arm64.tar.gz"
      sha256 "381db6d78cb315e36f3933be01d99407d76a4a9a83c461661aba680416027e0e"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.1/gitcrawl_0.1.1_linux_amd64.tar.gz"
      sha256 "65fed2e124ee6b3c6be413ac911a531e933be424491602c9cfc5fd0821b7c82d"
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
