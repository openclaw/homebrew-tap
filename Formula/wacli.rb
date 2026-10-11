class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.21.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.21.0/wacli_0.21.0_darwin_arm64.tar.gz"
      sha256 "c873f2f1ec545cc3a00ebf7b7fabb058dbbc0e7dd70e4d44acfcb31b0645d3b8"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.21.0/wacli_0.21.0_darwin_amd64.tar.gz"
      sha256 "6294603c5993d369bbd00f4f9a09d33991f54c370cd00b6fde097422152f8fac"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.21.0/wacli_0.21.0_linux_arm64.tar.gz"
      sha256 "f20ef44b9670cd4def5f5ad8bdb5b474e8bc03bdf02c23c19b94d73c47166b69"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.21.0/wacli_0.21.0_linux_amd64.tar.gz"
      sha256 "8b2e6fc3d75a27f8cdcf519f6ebc3b59ccbdf0a7505c2bee5967a05e4ecc6f78"
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
