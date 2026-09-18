# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.61.0/crabbox_0.61.0_darwin_amd64.tar.gz"
      sha256 "bf0c65841b2f0eaae340e0bd5f094893be92fbc9e9179cc52a0a0312a208bfa7"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.61.0/crabbox_0.61.0_darwin_arm64.tar.gz"
      sha256 "fa760aba47de3e89db9588f5cc152196f31c6b124c40aedb16f48bd80d805d00"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.61.0/crabbox_0.61.0_linux_amd64.tar.gz"
      sha256 "56ba9df85ff3832b05dad9f5c41e8c4c3fdd9fcf3dddc90063f64175e21684cc"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.61.0/crabbox_0.61.0_linux_arm64.tar.gz"
      sha256 "96a952930c190512932f1de1b1854008d5e0403dba0158f89888b5c85c6c8a06"
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
