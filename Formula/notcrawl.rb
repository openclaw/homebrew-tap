class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.10/notcrawl_0.6.10_darwin_arm64.tar.gz"
      sha256 "08c5c899299736cce3792f9b0b1909405e1e5166b7fafb38625fb2836076e566"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.10/notcrawl_0.6.10_darwin_amd64.tar.gz"
      sha256 "3a790b574b661eab00247d56f6779289c5d3f43fa4a8fe85219b45af0888d5b3"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.10/notcrawl_0.6.10_linux_arm64.tar.gz"
      sha256 "be643b426dcd59439ac6e49b117b63ff1190b447a4ca6a0ad9fc2f26059467bd"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.10/notcrawl_0.6.10_linux_amd64.tar.gz"
      sha256 "559988e8cf4d8f4c1c140c99fcad3419f46dc00cdee3f8078ea82083c9847a7b"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
