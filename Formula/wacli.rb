class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.18.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.0/wacli_0.18.0_darwin_arm64.tar.gz"
      sha256 "8282b5fab7c3a1cd0444d9f1d2701147cc85d40e54ced9c2e95407de75105b3b"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.0/wacli_0.18.0_darwin_amd64.tar.gz"
      sha256 "474fef235f189805e7f66615df1c98fa0ede15c52f04c157703967db6d2b0a3d"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.0/wacli_0.18.0_linux_arm64.tar.gz"
      sha256 "6440be3544de84df1df3598320e891d06c160ec33b35ef350c353feddeeb8ed3"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.18.0/wacli_0.18.0_linux_amd64.tar.gz"
      sha256 "7a36399c44f02aaed643d309c294d0a4b0c8264748561d46525aa9c9abd0b3a6"
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
