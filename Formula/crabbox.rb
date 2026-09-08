# typed: false
# frozen_string_literal: true

# Maintained in this tap; the ordinary updater preserves install behavior.
class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.53.0/crabbox_0.53.0_darwin_amd64.tar.gz"
      sha256 "3bb3aa933a4424f9aa78929118c3fa0c66d96a9e57ba0f16780a1f6d98f05816"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.53.0/crabbox_0.53.0_darwin_arm64.tar.gz"
      sha256 "fe613e0c3f5a3d204da2975b012b6b9a459af932bf8aaf86406211c35540d864"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.53.0/crabbox_0.53.0_linux_amd64.tar.gz"
      sha256 "86b26711543fed9b3869c5493be3528a665e2cb44b1cc0fb357c4b3ef0dd1e41"
      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.53.0/crabbox_0.53.0_linux_arm64.tar.gz"
      sha256 "41743f677b50b58738897f088b5f7ac226c61eb3dc0cd2f8f3bacd0202f270b6"
      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
  end

  test do
    system bin/"crabbox", "--version"
  end
end
