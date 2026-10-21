class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.8/notcrawl_0.6.8_darwin_arm64.tar.gz"
      sha256 "33e9729ce89dccecc14784b74a22e62330d32b45a4f2743a7cc1865c9a5b62ac"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.8/notcrawl_0.6.8_darwin_amd64.tar.gz"
      sha256 "23da2df290b8f5a7219d38ca554ee63c67a060cc6764b153abb86f7a031f3a28"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.8/notcrawl_0.6.8_linux_arm64.tar.gz"
      sha256 "2a371bddbc74e57ee66e68e4f088f8c8e0c84391dc1dad7f652678462fc9c96a"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.6.8/notcrawl_0.6.8_linux_amd64.tar.gz"
      sha256 "009ad69ce7f0389d87e2d92905563edb357dee585e3d233ed425a5e49538721d"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
