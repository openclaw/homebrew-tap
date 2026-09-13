# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.58.0/crabbox_0.58.0_darwin_amd64.tar.gz"
      sha256 "59d78b578c3c1ed1c78f9aac6b98cbec2c8567feca4d56cfde2ba531e407c369"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.58.0/crabbox_0.58.0_darwin_arm64.tar.gz"
      sha256 "a84d395ff935940449dd295b4453d993bfc4692350b3d2a8f45e09243eb1fa4e"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.58.0/crabbox_0.58.0_linux_amd64.tar.gz"
      sha256 "a1201e203d1c83ee0daee1ee2c451ad70ce032ecfdf196da2a8b2e118f07af78"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.58.0/crabbox_0.58.0_linux_arm64.tar.gz"
      sha256 "045bb84c1dca4ae9a02ddbf4b942c62213583ea8c1f15194ec4ab319d367aa34"
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
