class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.3/discrawl_0.11.3_darwin_arm64.tar.gz"
      sha256 "e6bc077a0632dabe7c611cdb24d0ef05f06113ce874df46a7ef79c90312f9668"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.3/discrawl_0.11.3_darwin_amd64.tar.gz"
      sha256 "1b961106647a059a2aa5f370889ae3973784751ba4590a6b8a3501ea4292c5a8"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.3/discrawl_0.11.3_linux_arm64.tar.gz"
      sha256 "6c0016825801cab085471a647207042e73b6e8d05af636be6163736cb2b7edc8"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.3/discrawl_0.11.3_linux_amd64.tar.gz"
      sha256 "0b9c2e6c24b087a7b29f93960c572cc1a77597d9a31f4876235f09b86d75b6c5"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
