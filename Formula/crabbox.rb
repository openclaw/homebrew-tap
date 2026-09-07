# typed: false
# frozen_string_literal: true

# Maintained in this tap; the ordinary updater preserves install behavior.
class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.52.0/crabbox_0.52.0_darwin_amd64.tar.gz"
      sha256 "524cf6ace46378f1a201a30a4d2de57bc70a0f696ab943a5afc95eb3871b41d3"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.52.0/crabbox_0.52.0_darwin_arm64.tar.gz"
      sha256 "2d3962ca1953a3d72fac74af21e6ef3410b8093e6804b3b5f392124c5be59f18"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.52.0/crabbox_0.52.0_linux_amd64.tar.gz"
      sha256 "cb832d52949aa4449dad459abc024b81ed599eea0dd572331d8181254f277f82"
      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.52.0/crabbox_0.52.0_linux_arm64.tar.gz"
      sha256 "bbfc8f5e5d189ab0b61dcbcac6976c5b2c2056bddb8795acc11e9818723abd59"
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
