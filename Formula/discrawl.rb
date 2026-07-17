class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.6"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.6/discrawl_0.11.6_darwin_arm64.tar.gz"
      sha256 "00b0c7cd6c0797153eb260b4f294f88e5f5c8446e4fe36632350179e6182bd78"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.6/discrawl_0.11.6_darwin_amd64.tar.gz"
      sha256 "10b2e35dc7fe7337d963dace766a915ad34f8c20f79c5f1c162e884183d0bf23"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.6/discrawl_0.11.6_linux_arm64.tar.gz"
      sha256 "b16cae2533e456ef85b9920cc0dea6efa97d6b543082504e6e729d9a559421cf"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.6/discrawl_0.11.6_linux_amd64.tar.gz"
      sha256 "3894d33128299502043e7899d0e236af05e9e844b3ab25dbeb3871739ea47c43"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
