# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.57.0/crabbox_0.57.0_darwin_amd64.tar.gz"
      sha256 "84656eeba91916d7c23898a13d89c5247d356890e078822c818bbe8ce0101eee"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.57.0/crabbox_0.57.0_darwin_arm64.tar.gz"
      sha256 "bba898561b4f5548047088ee761f2c3c74574c85af68fde792196b9f9b33c217"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.57.0/crabbox_0.57.0_linux_amd64.tar.gz"
      sha256 "3a395826da2fa7117149f160b25fc0586841664d3096754ca21bd85f1c7e9d37"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.57.0/crabbox_0.57.0_linux_arm64.tar.gz"
      sha256 "1a0618a18d556ad9c601e8882b6dc80aabfaedd3f5a447bec20bb56409df82d3"
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
