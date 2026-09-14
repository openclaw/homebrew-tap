# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.59.0/crabbox_0.59.0_darwin_amd64.tar.gz"
      sha256 "2cf3d832b72e78dd36ebbfd44f68b3a2a7d1518ab12aadf32adbec0aaa0363b8"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.59.0/crabbox_0.59.0_darwin_arm64.tar.gz"
      sha256 "abbcce01d49046a890ecb66ef30d5359f538912e06ad3deccb1d6e0fdf2536a3"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.59.0/crabbox_0.59.0_linux_amd64.tar.gz"
      sha256 "c561e943d361fcce81e3b2e66f33dc39d9c154fcae942130cf05b384e8ed7d9b"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.59.0/crabbox_0.59.0_linux_arm64.tar.gz"
      sha256 "54342dd94f8708be1662957c8712618ae136a6a2a61a6da686a159c88104e32f"
    end
  end

  def install
    bin.install "crabbox"
    bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
  end

  test do
    system bin/"crabbox", "--version"
  end
end
