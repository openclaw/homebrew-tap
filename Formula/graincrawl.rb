class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.4.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.7/graincrawl_0.4.7_darwin_arm64.tar.gz"
      sha256 "3529515b225581b26a052907780f75e2203ed84a9def925fe11081a43f540876"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.7/graincrawl_0.4.7_darwin_amd64.tar.gz"
      sha256 "0f55570b1b4c9927f087a2b1ac7df1a7c94e49ddc3df3c1cb91f5c1495c9f716"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.7/graincrawl_0.4.7_linux_arm64.tar.gz"
      sha256 "0cc01304f436086ec450bf97bb2eff5bc19813221e8213fcd9fd2029f5838bc4"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.4.7/graincrawl_0.4.7_linux_amd64.tar.gz"
      sha256 "dd345572c6a75dfefbd2d0065fc37027de69a1191242cacb4a18264d6ffcc67b"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl --json version")
  end
end
