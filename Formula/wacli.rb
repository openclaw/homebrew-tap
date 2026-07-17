class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.13.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.13.0/wacli_0.13.0_darwin_arm64.tar.gz"
      sha256 "9e6c1ddbe9e4163960689526b714213867533bc4b2eb656c345a4411b70ccdd5"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.13.0/wacli_0.13.0_darwin_amd64.tar.gz"
      sha256 "8c557e31a51646be8572dc66443179c4275f305fbac9a2ddd0961e73177fb675"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.13.0/wacli_0.13.0_linux_arm64.tar.gz"
      sha256 "54bcf9c16ae86f60edd9d5135baaaf5ffcada9b1a6f56f3616aeca223d126af1"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.13.0/wacli_0.13.0_linux_amd64.tar.gz"
      sha256 "147181bd5ef6ae38bdbccfc81c3ac913d4a8ec87b28713a5ecffc24fb46aa831"
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
