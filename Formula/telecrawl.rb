class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.3.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_darwin_arm64.tar.gz"
      sha256 "2734a2bb41fdafa9631f85b9734b38b5f2332023ad1982cebdbc3663c847592c"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_darwin_amd64.tar.gz"
      sha256 "d4b5e873e14fa9c573047db85519edc5c440cd4623bac2ceb40130c1779ed69e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_linux_arm64.tar.gz"
      sha256 "5a85f5e14a7fe30aedbf648106a452fc3cbdf3a7636ef6d2b11939a2e52a6209"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_linux_amd64.tar.gz"
      sha256 "64512f389b49f555539da75ab012e12fb1f1bde55cb4c5101bd7790e4fa3e0d5"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
