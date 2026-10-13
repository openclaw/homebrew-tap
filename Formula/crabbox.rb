# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.76.0/crabbox_0.76.0_darwin_amd64.tar.gz"
      sha256 "19b2f424aa8c4fe5d258be0ff6d9aa0393c0cf5f1f3a767506b3fd11d3a758a0"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.76.0/crabbox_0.76.0_darwin_arm64.tar.gz"
      sha256 "bbb8b2f45d31232adf326bda46c5d70a84a8e02b0cb6a1ebc14d1cec8d9e8285"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.76.0/crabbox_0.76.0_linux_amd64.tar.gz"
      sha256 "8d3ba11fe918b2477ae254045982d39ac550b4d0b8cc420d237ed95dd16d16d3"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.76.0/crabbox_0.76.0_linux_arm64.tar.gz"
      sha256 "705fdcd03b89d22bcd99b6e7a41b175a9658c5b36f0ab57af7e77e0700e75599"
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
