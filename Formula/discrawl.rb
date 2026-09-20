class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.4/discrawl_0.15.4_darwin_arm64.tar.gz"
      sha256 "c13b0cd990381f2f39e4b172849b0479fca5f4765b58dcfa8b1aba069adaebda"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.4/discrawl_0.15.4_darwin_amd64.tar.gz"
      sha256 "e75b04e68ae6d37368c9a4834709d326fa57fc898e9fb81c2279b6e978a8f318"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.4/discrawl_0.15.4_linux_arm64.tar.gz"
      sha256 "4f366699f388d43848377f42bd2076b1d36f114bd5f757215b350bdb9045f70e"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.4/discrawl_0.15.4_linux_amd64.tar.gz"
      sha256 "972c795acf8e479924fe6925ecd530e7c99c511e2523247f8ed5aa7c511a68bd"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
