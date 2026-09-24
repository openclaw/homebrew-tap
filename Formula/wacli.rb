class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.19.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.19.0/wacli_0.19.0_darwin_arm64.tar.gz"
      sha256 "d033cd1ee2c62cb60a3aae9d1c9abab8f5ac13b72a3a423ddf40d23284bf3d70"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.19.0/wacli_0.19.0_darwin_amd64.tar.gz"
      sha256 "1cbe652438f88b830ebbae7e5e8caa9e8381c1cc16da10a8c25bed6c871a1669"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.19.0/wacli_0.19.0_linux_arm64.tar.gz"
      sha256 "9047eefc9e9a6d37604c1a71ef6469d1127bb61bb75b99d929c76e0c1328d364"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.19.0/wacli_0.19.0_linux_amd64.tar.gz"
      sha256 "57ea00b26c0ffefa29758b2bcfc183b3e7b061271afee21cb0471a024f3c57ff"
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
