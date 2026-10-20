class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.7/notcrawl_0.6.7_darwin_arm64.tar.gz"
      sha256 "2f644d353feeda570e32d24c12c065105a0feb837c59b9f061da4e7120703bc4"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.7/notcrawl_0.6.7_darwin_amd64.tar.gz"
      sha256 "acae3b92e2dc239504ba77c2283fd4951f97c135d998c885691369a9e543497e"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.7/notcrawl_0.6.7_linux_arm64.tar.gz"
      sha256 "0f7a0d3b331251cfbf17788f8dd607c3a0c4f9a55c9e5aa1eed765bf90802f9a"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.7/notcrawl_0.6.7_linux_amd64.tar.gz"
      sha256 "88103c89e285a29e33ae55fd3caa7bf42fee6c2091fedc708338c5a22df35b55"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
