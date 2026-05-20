class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  license "MIT"
  head "https://github.com/openclaw/wacli.git", branch: "main"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.10.0/wacli_0.10.0_darwin_arm64.tar.gz"
      sha256 "a0c5c44dd22764d862fef2a1ff5aa65997e535b8b40db2c5b2ec04bfdb58ef42"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.10.0/wacli_0.10.0_darwin_amd64.tar.gz"
      sha256 "3a1b1f35190ac81fb25cdd3fc991641acd93e6711a79b4d4cdea9b54332a2962"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.10.0/wacli_0.10.0_linux_arm64.tar.gz"
      sha256 "7cdd0b5297e09230709bb50266e9f90436a876140af82cb725a8c3621bbe74b1"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.10.0/wacli_0.10.0_linux_amd64.tar.gz"
      sha256 "96a0b05937f0e129ab9bf6c0fcd30e4250ae764e4290a80743d10ed9d40e23eb"
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
    assert_match "wacli", shell_output("#{bin}/wacli --version")
    assert_match "FTS5", shell_output("#{bin}/wacli doctor")
  end
end
