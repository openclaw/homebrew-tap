class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.26.1"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.26.1/wacli_0.26.1_darwin_arm64.tar.gz"
      sha256 "20898523a70fb3ad992f8a20d786f70484bb53221df017cdafdcb7f7fc882d8f"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.26.1/wacli_0.26.1_darwin_amd64.tar.gz"
      sha256 "d5561a41534ec83be8bca611d1fcef12bbfb9967a3661dcc7d0328b929224a7d"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.26.1/wacli_0.26.1_linux_arm64.tar.gz"
      sha256 "9efe789b01e12462140089749d8b5ce0ad292521893f4166e13eca81f0acac4c"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.26.1/wacli_0.26.1_linux_amd64.tar.gz"
      sha256 "515405c5a33c7f651a368484740db662736f50c275be5a0504fb0a84dce47013"
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
