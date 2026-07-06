class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.12.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.12.0/wacli_0.12.0_darwin_arm64.tar.gz"
      sha256 "b614e4f78afcd7b9bd5d6b3209711eca151dc4aab9c1826719108eef45360672"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.12.0/wacli_0.12.0_darwin_amd64.tar.gz"
      sha256 "58a95d6009e2b3dc9bc947b2a1e8742865a066c78c59c152ed8293e2434ea8db"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.12.0/wacli_0.12.0_linux_arm64.tar.gz"
      sha256 "32be461045c03701101310137bdbc7a48a342f2f7d5317e996fbc7111a2f6145"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.12.0/wacli_0.12.0_linux_amd64.tar.gz"
      sha256 "49baa180fa7f0f4a694f683b8f7386ea64023ed79c0307037f0680bd21c116e0"
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
