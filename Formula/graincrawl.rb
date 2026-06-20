class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.1/graincrawl_0.3.1_darwin_arm64.tar.gz"
      sha256 "1e085668774d248c847a6dca41029e11538b1f7949bc39444abad02b3d27d497"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.1/graincrawl_0.3.1_darwin_amd64.tar.gz"
      sha256 "d5420652ce18c1e7e690bd1caab31645b60f06a4f26daffa0a5673f65e4c42bd"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.1/graincrawl_0.3.1_linux_arm64.tar.gz"
      sha256 "e521cd89fb184567e969079df79d49cb179a7603a20452273fee695141dd84d2"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.3.1/graincrawl_0.3.1_linux_amd64.tar.gz"
      sha256 "259e12ad0f517af9469a135bb109598069fe8413aa27ea782d4cddc418e9a782"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl version --json")
  end
end
