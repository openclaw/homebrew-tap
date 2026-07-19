class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.3.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.3/graincrawl_0.3.3_darwin_arm64.tar.gz"
      sha256 "7936437622e6e9a1fa0da2e53ae88c76c5d3b1f4f461466616f28319d2fa3cf2"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.3/graincrawl_0.3.3_darwin_amd64.tar.gz"
      sha256 "7f21bc167c2e8fc26693c872ea7438d2a121b623d12fbff55c2bab39675e7912"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.3/graincrawl_0.3.3_linux_arm64.tar.gz"
      sha256 "1d9ef648c317616f5e85d112a409d444baca07862aeb3d4c9f2fa64346d2ed04"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.3/graincrawl_0.3.3_linux_amd64.tar.gz"
      sha256 "091405e9d56767e7f558254f8dde77b1bcbe90cbc8d0be260c28e4bb92b6a1f3"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
