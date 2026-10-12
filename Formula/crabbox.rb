# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.75.0/crabbox_0.75.0_darwin_amd64.tar.gz"
      sha256 "21dd0301e7cfd669d7014c24778aef142e782f1f3e1faec8444c3dbc035e0bc1"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.75.0/crabbox_0.75.0_darwin_arm64.tar.gz"
      sha256 "785d4e391ef08d89ff75329e6634d3b3fe1dcae505543729ea30a8a223cddb69"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.75.0/crabbox_0.75.0_linux_amd64.tar.gz"
      sha256 "6f01491c231e604e8a0af8f98f38476a851e84119c82349b217da989418690cf"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.75.0/crabbox_0.75.0_linux_arm64.tar.gz"
      sha256 "375ec198ec2cc4648a1b37b05859c2a9e5250d3ad90b5b6c94c7dbcc8e2a7c74"
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
