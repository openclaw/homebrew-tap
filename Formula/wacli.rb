class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.11.2"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.2/wacli_0.11.2_darwin_arm64.tar.gz"
      sha256 "842bdd865b2c7a07e386825e1d8a89bfd679e0851de91ccaf299b1a4bbb05901"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.2/wacli_0.11.2_darwin_amd64.tar.gz"
      sha256 "ff46891f54f716c7a311328fd8462715c69ea41cd3f0e2db34f5ec166704aaf2"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.2/wacli_0.11.2_linux_arm64.tar.gz"
      sha256 "8660314fadd92bca19381c8194f92930df153f50ee6eb37eac9ae44c2e25d544"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.2/wacli_0.11.2_linux_amd64.tar.gz"
      sha256 "cfb3a44e1d15ff4568671d3d40a1ccb88bc7db75678e340db8b4196e7762565d"
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
