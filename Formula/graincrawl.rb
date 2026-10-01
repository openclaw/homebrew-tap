class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.4.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.5/graincrawl_0.4.5_darwin_arm64.tar.gz"
      sha256 "ef7ce97d4e19e629a6301c75acdbacb6d17dc1221a44f47b03d7086f3b9da6e7"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.5/graincrawl_0.4.5_darwin_amd64.tar.gz"
      sha256 "f20a72b3134530bcb40d2dbfaafe73d650a8d9be57aaf1b83d318f70cf5ce70a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.5/graincrawl_0.4.5_linux_arm64.tar.gz"
      sha256 "0c2971d596c84b6b7c69417de9b2a864faf8ea367a44d9e89c56adbc3b04fbb2"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.5/graincrawl_0.4.5_linux_amd64.tar.gz"
      sha256 "f3ad1c75dc2b37d67636e7b68d6732f081cceb042d1b795f41b5a6657dc448eb"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
