class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.18.3"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.3/wacli_0.18.3_darwin_arm64.tar.gz"
      sha256 "c43f8c09d51c3fea5b9d29a04afcdfd6ddc48af11b0ec581e6b2ff608412e701"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.3/wacli_0.18.3_darwin_amd64.tar.gz"
      sha256 "4a685621a4018f917ab5c8de90329b98387ac2a406eab39baeae3080cdd9ac72"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.3/wacli_0.18.3_linux_arm64.tar.gz"
      sha256 "bdb0cf8b4addcc5fd3adde2b6b816bb07357acc4463d4b70f39ad4c919aeca8c"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.3/wacli_0.18.3_linux_amd64.tar.gz"
      sha256 "a8b42ae59489d9377bd76d88da0faf92b8432c5c6e5f957cef619c04ae5b3018"
    end
  end

  def install
    if File.exist?("wacli")
      bin.install "wacli"
    else
      ldflags = "-s -w -X main.version=#{version}"
      # GCC 15+ with glibc 2.42+ treats missing-braces in Go's runtime/cgo as errors.
      # See: https://github.com/steipete/wacli/pull/8
      ENV["CGO_ENABLED"] = "1"
      ENV.append "CGO_CFLAGS", "-Wno-error=missing-braces"
      system "go", "build", "-tags", "sqlite_fts5", *std_go_args(ldflags: ldflags), "./cmd/wacli"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wacli --version")
    assert_match "FTS5", shell_output("#{bin}/wacli doctor")
  end
end
