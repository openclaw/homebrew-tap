class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.11/notcrawl_0.6.11_darwin_arm64.tar.gz"
      sha256 "727061df376e32c9c35279ddb5c8170361d852f475ca03e6b6ff174cbe407097"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.11/notcrawl_0.6.11_darwin_amd64.tar.gz"
      sha256 "65edca48ba8ee7e2e5f598315fd9c0cc36d70556505b77ff465feba5ec683655"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.11/notcrawl_0.6.11_linux_arm64.tar.gz"
      sha256 "a8eaf2e2c336e0d40e67773ba637a818ed2c41b78063216728ce2a2a7c26fdb1"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.11/notcrawl_0.6.11_linux_amd64.tar.gz"
      sha256 "293cdcb43d9934a62215619145ea961d683424b4713b4a1c1daf2acc5695617f"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
