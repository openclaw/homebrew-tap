class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.22.0"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.22.0/wacli_0.22.0_darwin_arm64.tar.gz"
      sha256 "da3f528e0c65b743d451b360b9dea14d784fb209a2e9f8b8b9c00498d8f619fe"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.22.0/wacli_0.22.0_darwin_amd64.tar.gz"
      sha256 "28a4c1402e61c0578a46ecd8871547e231c24b20b4f54b8ccbb7e367dfe67732"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.22.0/wacli_0.22.0_linux_arm64.tar.gz"
      sha256 "a6022010ee862e3b60ca46d486e22e9389589ae333f0395f47f7382b50cd0902"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.22.0/wacli_0.22.0_linux_amd64.tar.gz"
      sha256 "747745eac681e7102ccb714f46566b8260a4ec02debc86b6c27c8dfd0e40808a"
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
