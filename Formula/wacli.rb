class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.18.1"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.1/wacli_0.18.1_darwin_arm64.tar.gz"
      sha256 "8541d05c7465795679f957867dbdb7927fa9724f05c5477b08b12f9b60c41bfb"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.1/wacli_0.18.1_darwin_amd64.tar.gz"
      sha256 "664eb9c29c390dcf9b34267ccefe687a60d9f9b2f7f58de3a177635c7eabe1d2"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.1/wacli_0.18.1_linux_arm64.tar.gz"
      sha256 "e41465ac95baea79586d43ea102adb501abd0aa84f371138a9a1bda625bfc01d"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.1/wacli_0.18.1_linux_amd64.tar.gz"
      sha256 "36e8c48065f224f58428db9802767e8c6d9e10c0e847bbb5d9072fac72c272cd"
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
