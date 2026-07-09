class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  version "0.5.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.2/notcrawl_0.5.2_darwin_arm64.tar.gz"
      sha256 "ccd2a737558a301722ef496506883d3d09aca987e5f126fc2683e4eecdd06cc6"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.2/notcrawl_0.5.2_darwin_amd64.tar.gz"
      sha256 "cbb3b531527330a6e7144ea8792389b98719c45556fa2a9d2fcc070b46439bdb"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.2/notcrawl_0.5.2_linux_arm64.tar.gz"
      sha256 "af6fa425febaaedd4065517c91b3455da0603f0c5985068bc0a466076767ac09"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.2/notcrawl_0.5.2_linux_amd64.tar.gz"
      sha256 "52c6e93917cd754eceabb231183a3dde91d51bec36d2fc604d8f63f871444320"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
