class Gitcrawl < Formula
  desc "Local-first GitHub issue and pull request crawler for maintainer triage"
  homepage "https://github.com/openclaw/gitcrawl"
  version "0.1.0"
  license "MIT"

  head "https://github.com/openclaw/gitcrawl.git", branch: "main"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.0/gitcrawl_0.1.0_darwin_arm64.tar.gz"
      sha256 "bb3541bb671ac980a0a362c96d4b0ec060e20a8107fa69b1155181bf3215b370"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.0/gitcrawl_0.1.0_darwin_amd64.tar.gz"
      sha256 "f270bc5706995b21cb81ac0f43ab0ad0bbcccda2151f4b61b69d6640689f1c75"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.0/gitcrawl_0.1.0_linux_arm64.tar.gz"
      sha256 "644f31268efe07b4a05edd5249bf5a0ee28961b25069efa4c93afe00814fce6b"
    else
      url "https://github.com/openclaw/gitcrawl/releases/download/v0.1.0/gitcrawl_0.1.0_linux_amd64.tar.gz"
      sha256 "dcd1da3db56e61afdacb055f16e142a3a4442bb63cc4bfbd2de574a9f3dadb17"
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
