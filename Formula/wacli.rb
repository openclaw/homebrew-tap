class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  license "MIT"
  head "https://github.com/openclaw/wacli.git", branch: "main"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.0/wacli_0.11.0_darwin_arm64.tar.gz"
      sha256 "0f4346fd054ff58d73fbbb91da510eb70b643af049fa819d9a365b4b1c6872f5"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.0/wacli_0.11.0_darwin_amd64.tar.gz"
      sha256 "094fa710bfcbab0a78ff9060d8e2b5f6805b9da5e0072ee2ab24bffd0d736d6c"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.0/wacli_0.11.0_linux_arm64.tar.gz"
      sha256 "8e50fd66ff6f381662666563376172ce2e1b44ad5410af4e6c276cc0c7765055"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.0/wacli_0.11.0_linux_amd64.tar.gz"
      sha256 "8fe8f14694cd439b066db8ced8689cff5653f4aac1904b25a639e1560492ae43"
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
    assert_match "wacli", shell_output("#{bin}/wacli --version")
    assert_match "FTS5", shell_output("#{bin}/wacli doctor")
  end
end
