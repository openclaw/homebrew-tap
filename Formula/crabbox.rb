# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.78.0/crabbox_0.78.0_darwin_amd64.tar.gz"
      sha256 "a380218f79c9eea9043ece69c2abceebbb37d4a314c3d2e4ac2a519251c24cef"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.78.0/crabbox_0.78.0_darwin_arm64.tar.gz"
      sha256 "b3f0095d9ef4b9a1d30eab720921569db471babb41cfc5641cab7d272a602414"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.78.0/crabbox_0.78.0_linux_amd64.tar.gz"
      sha256 "0d13a159c2ceafc3635aede79baf0e6d3d7a3d8f34276ca880502c64f635ee60"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.78.0/crabbox_0.78.0_linux_arm64.tar.gz"
      sha256 "4db4ef818f9b4da2a801e9aafd87ba6536467078409478550983821e176d33d4"
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
