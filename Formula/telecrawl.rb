class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.3.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_darwin_arm64.tar.gz"
      sha256 "f603306d355992773ddbf2c2cf95c1a7ce94d1fb70750124a5e35c0ab1df3904"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_darwin_amd64.tar.gz"
      sha256 "9bcd9c2bf99e620f71c43d69f7bc4fabf31e055c270dd3337c1cd4c690576039"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_linux_arm64.tar.gz"
      sha256 "1364bddd3d181cb3a2f2a1efd0551f2f42dc54cd78bd7c81ba18b3ee1ccf4078"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v#{version}/telecrawl_#{version}_linux_amd64.tar.gz"
      sha256 "5c8f45e09be05902a705b3e2dc6532ab1571117b115dfd12ff897489f6fe2ae9"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
