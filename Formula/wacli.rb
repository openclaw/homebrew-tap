class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.23.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.23.0/wacli_0.23.0_darwin_arm64.tar.gz"
      sha256 "d2b667b1ad5db33913e8ae63f45be984bc5fee379fb8e65f68cf55b6fad50a62"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.23.0/wacli_0.23.0_darwin_amd64.tar.gz"
      sha256 "81a466b6170d3595c8ea28e4a5dab03c0195e5b0311a32ea00c859f7d3fe1693"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.23.0/wacli_0.23.0_linux_arm64.tar.gz"
      sha256 "2852aeaee35e368f662d83cb3c15b93da0de9db21cae6e274115b45e6c82325f"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.23.0/wacli_0.23.0_linux_amd64.tar.gz"
      sha256 "5c6b921741ab19910fb6b958c9af9a74e99e385dac8c273b01cd1158359aaf8b"
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
