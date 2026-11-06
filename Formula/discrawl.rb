class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.20.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.20.0/discrawl_0.20.0_darwin_arm64.tar.gz"
      sha256 "3aa9dc3d1ef89a6931bd42d044655dc0c56e14c1fddb52fd887f29a99ff54df2"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.20.0/discrawl_0.20.0_darwin_amd64.tar.gz"
      sha256 "0178ad45fd59a87fcde93ec6786a86c243939f40a214db28262f1139bf0df8e2"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.20.0/discrawl_0.20.0_linux_arm64.tar.gz"
      sha256 "c09f0b3088f04413aec2aba1be26b1b2c6d8428dd9a0557129e4292d6a5ad5e9"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.20.0/discrawl_0.20.0_linux_amd64.tar.gz"
      sha256 "5da5db98d6a6f43e2ffc319713d8f3c4899918cd157560379fc1693b9b57f8b7"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
