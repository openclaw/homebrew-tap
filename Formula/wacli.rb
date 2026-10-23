class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.25.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.25.0/wacli_0.25.0_darwin_arm64.tar.gz"
      sha256 "ede9170ac661c8bef9c5fd449b29611301c0b63947a9ffad818dd9ec981a47a1"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.25.0/wacli_0.25.0_darwin_amd64.tar.gz"
      sha256 "b8a8919fbcd16e3c258bf9c98b851d7986c4efd4344db95dc1a6a06075054f50"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.25.0/wacli_0.25.0_linux_arm64.tar.gz"
      sha256 "9282c3eabe4a445db057ac1e379b14648bbccb94d7b486f0b960ed8dde63ff82"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.25.0/wacli_0.25.0_linux_amd64.tar.gz"
      sha256 "9cbee5b7779b5670bd16dcf8feda2294a11e4acc801d9837ef9cd1a6619fc73c"
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
