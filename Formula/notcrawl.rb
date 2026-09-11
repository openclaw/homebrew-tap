class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.1/notcrawl_0.6.1_darwin_arm64.tar.gz"
      sha256 "39476ebca70203bb6490d38cccc72ff9e553a7c77fd39ec2727e81a7beb45c57"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.1/notcrawl_0.6.1_darwin_amd64.tar.gz"
      sha256 "d995849ef5b5bba93cd1fbd469fdcafb5f4d82bfe6b535d851f6e502beb21dc9"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.1/notcrawl_0.6.1_linux_arm64.tar.gz"
      sha256 "d80b2a3e609f2ec52c95b1bc90457485691ae9acc30ba7310df177877b4f1a22"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.1/notcrawl_0.6.1_linux_amd64.tar.gz"
      sha256 "847ff6c93af9aa1b4f56a161207ef4c5b5544a4a06fc357f5b7c5cc49fe75d3a"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
