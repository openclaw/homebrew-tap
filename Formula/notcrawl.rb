class Notcrawl < Formula
  desc "Local-first Notion crawler into SQLite and normalized Markdown"
  homepage "https://github.com/openclaw/notcrawl"
  version "0.3.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.3.6/notcrawl_0.3.6_darwin_arm64.tar.gz"
      sha256 "abbeb4db9d076f76ad8f511bea6d4ff3e8c23cd2af540a3ab55117edf9db49dc"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.3.6/notcrawl_0.3.6_darwin_amd64.tar.gz"
      sha256 "e8b810ae99454e0a723b4e02241e6f034b94b4948b13969c48a6a9abdd9df76c"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/notcrawl/releases/download/v0.3.6/notcrawl_0.3.6_linux_arm64.tar.gz"
      sha256 "5cc09d3679839fd936fc1f30e808cd179fb9bec61575303a6201ee4a7f680d1e"
    else
      url "https://github.com/openclaw/notcrawl/releases/download/v0.3.6/notcrawl_0.3.6_linux_amd64.tar.gz"
      sha256 "dea5c534f94757c97ddce774238e02744d300eb25f38b680ba374ade74ca72aa"
    end
  end

  def install
    bin.install "notcrawl"
  end

  test do
    assert_match "Usage of notcrawl:", shell_output("#{bin}/notcrawl --help")
  end
end
