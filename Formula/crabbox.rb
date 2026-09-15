# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.60.0/crabbox_0.60.0_darwin_amd64.tar.gz"
      sha256 "05b474ed2fa0a14f2cff6718aa8c4ef9abad326ddf2dc3457a0fe26d1416f5f9"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.60.0/crabbox_0.60.0_darwin_arm64.tar.gz"
      sha256 "2f69e9fb79843a6e5e933134bdf4aca85a66e2d97fdb1dde47a297d4f3f54e96"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.60.0/crabbox_0.60.0_linux_amd64.tar.gz"
      sha256 "778bf5c6569222390dbd8ae11da6f514cb579b5aea341f2d7acaba0644280e09"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.60.0/crabbox_0.60.0_linux_arm64.tar.gz"
      sha256 "74427832987727ebc75b002d3af262065ce7a356c0f7e2be027d7ee8021b932c"
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
