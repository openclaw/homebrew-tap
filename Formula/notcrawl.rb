class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.3/notcrawl_0.6.3_darwin_arm64.tar.gz"
      sha256 "5c939c1e0d3316532cda2f9c67c5bf1a8a2f49fdb20029e1354a3b65eef9ce4e"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.3/notcrawl_0.6.3_darwin_amd64.tar.gz"
      sha256 "aa8422152b3711b109846d3b6cfed5a08c022d050e302e282938a1ed219d4cf2"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.3/notcrawl_0.6.3_linux_arm64.tar.gz"
      sha256 "cc0cfb211cd692d04b3243d851022e0df23e69c174110dd262b56056e91fa199"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.3/notcrawl_0.6.3_linux_amd64.tar.gz"
      sha256 "9c378fbfdf5f5c9cb9f9651408818a58c08dffdd1096f6d6f2811bfafd88770a"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
