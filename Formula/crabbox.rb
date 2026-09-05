# typed: false
# frozen_string_literal: true

# Maintained in this tap; the ordinary updater preserves install behavior.
class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.50.0/crabbox_0.50.0_darwin_amd64.tar.gz"
      sha256 "ef12fc41138921e55435f24b51bd49d141a3bff5dd6b384df43222237c6c6d53"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.50.0/crabbox_0.50.0_darwin_arm64.tar.gz"
      sha256 "ace9f32571c94316c8517be5dea61702375896c49b0f4a657ae573831899545e"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.50.0/crabbox_0.50.0_linux_amd64.tar.gz"
      sha256 "8ab55a0302e7119a45e7522c2fff2d4e295496c33766c87cf619f342824cab75"
      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.50.0/crabbox_0.50.0_linux_arm64.tar.gz"
      sha256 "12f0ef90ff63c2429bbec29c699c744944382dcd9a072c46733db0011b8b1900"
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
