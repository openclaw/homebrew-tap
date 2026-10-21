class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.24.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.24.0/wacli_0.24.0_darwin_arm64.tar.gz"
      sha256 "d47416b1b67fac7af9593f9a56f1cca6f377ea4b0486a8766dbb80f10cfdef6f"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.24.0/wacli_0.24.0_darwin_amd64.tar.gz"
      sha256 "71d49ce8effdd860d5d68c02627c0d68214e1a7980012228d0d2c82a9403ea38"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.24.0/wacli_0.24.0_linux_arm64.tar.gz"
      sha256 "6e0fb54473deb0fb8782393cf1f21f0c1e3bb3301b3651cd9d9a77b6378f0e07"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.24.0/wacli_0.24.0_linux_amd64.tar.gz"
      sha256 "4ca5c668d41f68bad18bf12e7966aba7c1b3cc6ae32fd8e145deb987ddd1192d"
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
