# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.68.0/crabbox_0.68.0_darwin_amd64.tar.gz"
      sha256 "5867cc88a29927b7a554c0d8dcac20c8cc3a5935329f9af27d2f20788f3d9ba0"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.68.0/crabbox_0.68.0_darwin_arm64.tar.gz"
      sha256 "b2b5e80a0ad5bccd023daff333ef95ad301ea5b1da014b13275abba0e106237e"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.68.0/crabbox_0.68.0_linux_amd64.tar.gz"
      sha256 "973eda094e6edadc9b2c5e16ddd9d3a9b2817f774e4b5c70b9aae460265048d3"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.68.0/crabbox_0.68.0_linux_arm64.tar.gz"
      sha256 "5f89c7bf58ce182ae8b1c56ec94aa1391c8212770bb47934e54611b8a59e2ead"
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
