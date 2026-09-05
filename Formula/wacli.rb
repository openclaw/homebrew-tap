class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  version "0.17.2"
  license "MIT"
  version_scheme 1
  head "https://github.com/openclaw/wacli.git", branch: "main"

  depends_on "go" => :build if build.head?

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.17.2/wacli_0.17.2_darwin_arm64.tar.gz"
      sha256 "cae71bef8645b68aba37c7a3613cbc5354479021800ee9bc468156222bc27923"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.17.2/wacli_0.17.2_darwin_amd64.tar.gz"
      sha256 "2697e30223e50700ca75996c7dc7899e5a346e55358f9f35bdab024ed8ca5362"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.17.2/wacli_0.17.2_linux_arm64.tar.gz"
      sha256 "66a6be50191d6a7ee3d13940bd1049f72e9e28b97fc32179c2eae0d9b593ab61"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.17.2/wacli_0.17.2_linux_amd64.tar.gz"
      sha256 "25e54110ad8643f714fdc8e5b93d24f023adde535348869718c99c2cd0683ad7"
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
