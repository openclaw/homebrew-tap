# typed: false
# frozen_string_literal: true

# Maintained in this tap; the ordinary updater preserves install behavior.
class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.56.0/crabbox_0.56.0_darwin_amd64.tar.gz"
      sha256 "80b2ea3031e6187b20e168e36e0e04c02420dcc87dffec3663a50b252950038c"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.56.0/crabbox_0.56.0_darwin_arm64.tar.gz"
      sha256 "b19d994bc6d84a546c2002128312b2de5170038cc9497da3e6fb1627d4ca8e51"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.56.0/crabbox_0.56.0_linux_amd64.tar.gz"
      sha256 "0d1ae47b8d99eea986dd01f0fd0bf41d433826b817b28518c8d00a7e4207da7b"
      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.56.0/crabbox_0.56.0_linux_arm64.tar.gz"
      sha256 "e963566d92a8308f2cc67471c8dab9b683627e2e5760cbd391ece5361e7dd1f8"
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
