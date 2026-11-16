class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.21.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.21.0/discrawl_0.21.0_darwin_arm64.tar.gz"
      sha256 "8f01e505ee0c3b0119c740b3d4e19725aca21ef8222a1f9e9b52cc3d4a4af702"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.21.0/discrawl_0.21.0_darwin_amd64.tar.gz"
      sha256 "af4e756f6d657f1887056edf0a5b60f13540a4567d4a79da984ce803ef2f18b2"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.21.0/discrawl_0.21.0_linux_arm64.tar.gz"
      sha256 "78d70b437778f5f8f612bf81cc2c427fbab381db9b80a6313e85f43e54595212"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.21.0/discrawl_0.21.0_linux_amd64.tar.gz"
      sha256 "0ec98448c820519e1230d0a6ea7039a12b4bb781848d8b6f6e469e4126627902"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
