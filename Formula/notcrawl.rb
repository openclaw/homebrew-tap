class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  version "0.5.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.1/notcrawl_0.5.1_darwin_arm64.tar.gz"
      sha256 "82f1129fe6c008698a5a1add072ecc7958b25670eba4caabe5bedb1584fb7013"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.1/notcrawl_0.5.1_darwin_amd64.tar.gz"
      sha256 "a71467a3e767689a715d8f7c98f79e9c7bdedfffa4f0e7d30986bfcf9daa2393"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.1/notcrawl_0.5.1_linux_arm64.tar.gz"
      sha256 "98d38ca36e4c1323414bc1808bc2d618016c4f8c90021656ddcec259c502ec4c"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.5.1/notcrawl_0.5.1_linux_amd64.tar.gz"
      sha256 "901e03a4ef389becca4c003513a345c016ea96dc4427b4db07a84e44dc556df2"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
