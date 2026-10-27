class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.25.1"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.25.1/wacli_0.25.1_darwin_arm64.tar.gz"
      sha256 "fcb25052e2a4c6db6fb50eee5ee8c13ddf524111e47130dd22e101e879995e67"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.25.1/wacli_0.25.1_darwin_amd64.tar.gz"
      sha256 "2ab332120c0e5fd7356c8f1bd9e536f67dbd620584cb39e88d45df79b3267cea"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.25.1/wacli_0.25.1_linux_arm64.tar.gz"
      sha256 "798ea62226c5017fe2d7c7642d614afae7ea1b30376081b529910bf8f9ab2ce2"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.25.1/wacli_0.25.1_linux_amd64.tar.gz"
      sha256 "53bbb450f0a47e3b080173d61fd6cec72241d8065bee17e592275983b7abd281"
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
