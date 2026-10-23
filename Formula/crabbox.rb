# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.2/crabbox_0.79.2_darwin_amd64.tar.gz"
      sha256 "f084bec3bb5e34a7e5ebd0b33667f928f0a7bc34b457013cffc3206d0a0f1a04"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.2/crabbox_0.79.2_darwin_arm64.tar.gz"
      sha256 "2430b935b1ad37d59bae0d84258de9ed1c5de55706ae7a29ae26b805c27d3deb"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.2/crabbox_0.79.2_linux_amd64.tar.gz"
      sha256 "316e2d788c9f85d0a7e876a0a91eab5e0a9257b8c572ca2c1372dbe066395dae"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.2/crabbox_0.79.2_linux_arm64.tar.gz"
      sha256 "2099932addfe26acc0bd3861d17fade48324a5a4eddeb79862f8a2cc918e35b4"
    end
  end

  def install
    companions = %w[crabbox-jj-source crabbox-jj-source.json crabbox-jj-source.NOTICES.txt attribution.json]
    native_source = companions.any? { |file| File.exist?(file) || File.symlink?(file) }
    if native_source && companions.any? { |file| !File.file?(file) || File.symlink?(file) }
      odie "Incomplete native JJ companion bundle"
    end

    bin.install "crabbox"
    bin.install "crabbox-runtime" if File.directory?("crabbox-runtime")
    bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
    bin.install companions if native_source
  end

  test do
    system bin/"crabbox", "--version"
  end
end
