class Graincrawl < Formula
  desc "Local-first Granola crawler into SQLite and Markdown"
  homepage "https://github.com/openclaw/graincrawl"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.2.0/graincrawl_0.2.0_darwin_arm64.tar.gz"
      sha256 "978ac8a47312afd2935164ca25b755e6c185857f3c1c85f9ada26eff873c548a"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.2.0/graincrawl_0.2.0_darwin_amd64.tar.gz"
      sha256 "6b4aee287f4bf44f114268915401e6131dbc729ddbfa2cdc63fbdbac89870803"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/graincrawl/releases/download/v0.2.0/graincrawl_0.2.0_linux_arm64.tar.gz"
      sha256 "2db1f2bb311fe317af3ac26f0234dd9429b881ba68c0f9771be567feee620fe2"
    else
      url "https://github.com/openclaw/graincrawl/releases/download/v0.2.0/graincrawl_0.2.0_linux_amd64.tar.gz"
      sha256 "5c7e5993ef470b6cbe0fc51118753ea0b52a1dae02f588310ce92c8242596bfb"
    end
  end

  def install
    bin.install "graincrawl"
  end

  test do
    assert_match "\"version\"", shell_output("#{bin}/graincrawl version --json")
  end
end
