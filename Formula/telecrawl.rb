class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.3.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_darwin_arm64.tar.gz"
      sha256 "d91d1aeb8b6340c201d09112a9ea537d7eb4bcb9250aeaa1ca7ec4180a098c1d"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_darwin_amd64.tar.gz"
      sha256 "371f87061150ec81ec5c5375db430266d04598ff4b7c825902810944001651cd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_linux_arm64.tar.gz"
      sha256 "bd27c16230dabef59819e617ed02ac288a6d440aaf41fd44acbc5295bfbc0629"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_linux_amd64.tar.gz"
      sha256 "aafd1105426e84f890f0b72bce83debdc38e3ba5f4c127778aba07de6e3a89e1"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
