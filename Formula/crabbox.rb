# typed: false
# frozen_string_literal: true

# Maintained in this tap; the ordinary updater preserves install behavior.
class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.54.0/crabbox_0.54.0_darwin_amd64.tar.gz"
      sha256 "96afa5df758bed3871d145835c182d5e81f522468b8a5e647f2c639a6bc70b57"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.54.0/crabbox_0.54.0_darwin_arm64.tar.gz"
      sha256 "0f7647c23da98053979bf28148db93444a3b8ce090ccda0e6c28f1a2f0a8ed70"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.54.0/crabbox_0.54.0_linux_amd64.tar.gz"
      sha256 "8845cd05798bf842ed2ebf7678249fbcdfa5cba017e80b5f3950c1203ca6738b"
      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.54.0/crabbox_0.54.0_linux_arm64.tar.gz"
      sha256 "f61d17f77771c706819070de709b452f63f3ef54a1de99782c2668ac82ec08d8"
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
