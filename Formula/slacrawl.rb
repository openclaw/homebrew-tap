class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.9.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.9.1/slacrawl_0.9.1_darwin_arm64.tar.gz"
      sha256 "e93f12b62f7fa22556018d50082f87121657980c9a13c96947fc7400d27c416a"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.9.1/slacrawl_0.9.1_darwin_amd64.tar.gz"
      sha256 "ef9958ae7cc8a5fea90a9baa9cc0de63d4b18a1ddd120b8ecbd5aff334bd89dc"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.9.1/slacrawl_0.9.1_linux_arm64.tar.gz"
      sha256 "5ed20ec25bdf3e307e7b9d7e42618b6e44d8a9bb48ead652365ca4f7f8355350"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.9.1/slacrawl_0.9.1_linux_amd64.tar.gz"
      sha256 "c42e59794fa76814a034b932fc4b50bb804b70163fde04423131e248621476b9"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
