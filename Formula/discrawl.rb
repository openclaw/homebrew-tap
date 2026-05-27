class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.10.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
     url "https://github.com/openclaw/discrawl/releases/download/v0.10.0/discrawl_0.10.0_darwin_arm64.tar.gz"
      sha256 "64203c3e1d01b9c9369263e41a779b699f8b45978f18448599f8a18004ee2527""
    else
     url "https://github.com/openclaw/discrawl/releases/download/v0.10.0/discrawl_0.10.0_darwin_amd64.tar.gz"
      sha256 "7f5fb374c5aec322e92d8d7171f20773d084bbf15b89da95e055c2e2d7b58d0d""
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
     url "https://github.com/openclaw/discrawl/releases/download/v0.10.0/discrawl_0.10.0_linux_arm64.tar.gz"
      sha256 "8976f688a9a483e565b6da486e37015431122fa826186292ca079653586c7e37""
    else
     url "https://github.com/openclaw/discrawl/releases/download/v0.10.0/discrawl_0.10.0_linux_amd64.tar.gz"
      sha256 "14a1e0b00f342dac7397ee1f8257979390e10a103ff8f162612cb9ea7004db9c""
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
