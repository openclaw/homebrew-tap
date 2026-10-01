class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.20.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.20.0/wacli_0.20.0_darwin_arm64.tar.gz"
      sha256 "109db7f8f9f6033d948c3c61aed46a2e69944fbc96e154867df0d706df188da4"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.20.0/wacli_0.20.0_darwin_amd64.tar.gz"
      sha256 "fd5ec9df7b281d02f9b433deb718c1ebe4b1f410ebdb89b8a076bfd7f1263d95"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.20.0/wacli_0.20.0_linux_arm64.tar.gz"
      sha256 "fffcb19601b72a4cd3edfb8560fecc6f850b9be5a803e2b9a69a100f59595831"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.20.0/wacli_0.20.0_linux_amd64.tar.gz"
      sha256 "f243ea7c70f7ff8fc4de7fd7eb478698708acbd8470ad38ffc13379806321e8c"
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
