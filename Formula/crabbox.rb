# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.63.0/crabbox_0.63.0_darwin_amd64.tar.gz"
      sha256 "70467d01163c23e7a35aa191956d26730ccac105fdf9b4d0afa76e20ae28cac0"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.63.0/crabbox_0.63.0_darwin_arm64.tar.gz"
      sha256 "92f4eef04554c196a62fef2e75ae3f04398b9c5fc1fa9ae8b4074f6b68f7b830"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.63.0/crabbox_0.63.0_linux_amd64.tar.gz"
      sha256 "d04e2a209b07702c32177ab6fd1a442c90981746a0dc5f18f7abe9fa00d5cf5d"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.63.0/crabbox_0.63.0_linux_arm64.tar.gz"
      sha256 "6e44bb2963371f2363f88169e499d3180493cd6fd0358fbe8509a48b054aea91"
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
