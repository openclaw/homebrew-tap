class Wacli < Formula
  desc "WhatsApp CLI built on whatsmeow"
  homepage "https://github.com/openclaw/wacli"
  license "MIT"
  head "https://github.com/openclaw/wacli.git", branch: "main"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.1/wacli_0.11.1_darwin_arm64.tar.gz"
      sha256 "8d31c923994f0d7b3579c544de3ca760192d8506174758eaf55050d91675885d"
    end

    if Hardware::CPU.intel?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.1/wacli_0.11.1_darwin_amd64.tar.gz"
      sha256 "d07bdac1c7a4a7e697a4df6f4f65ad72d705b4fa65e55726868134fdf2449a8d"
    end
  end
  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.1/wacli_0.11.1_linux_arm64.tar.gz"
      sha256 "3ff0cf7df8f0ce5705570b67623a144b34a1ad433df308deaed2e604596f130c"
    end

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/wacli/releases/download/v0.11.1/wacli_0.11.1_linux_amd64.tar.gz"
      sha256 "07c8e7d01673d6fea92e98175f8bde4b9b17846cc46d857f91b268bf7cb8bf98"
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
