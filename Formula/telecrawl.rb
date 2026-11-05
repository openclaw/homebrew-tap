class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.6.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.6.0/telecrawl_0.6.0_darwin_arm64.tar.gz"
      sha256 "2b864b27571c5a8e16adb3eaefeb862a1e81dc0a421dcedf77e74adf65c458fe"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.6.0/telecrawl_0.6.0_darwin_amd64.tar.gz"
      sha256 "94a3b098a3fe77760e95357a705e100583d28d897a9902b31c7083f1a80e4f08"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.6.0/telecrawl_0.6.0_linux_arm64.tar.gz"
      sha256 "078d3ba54e6256574b6c40fdff2285aed226252da6c84843a19c0686668e5493"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.6.0/telecrawl_0.6.0_linux_amd64.tar.gz"
      sha256 "1b72dd6dbae8a3d806edb23827bc09dca3a0847c774c62c574d9f5dc419f0179"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
