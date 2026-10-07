# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.72.0/crabbox_0.72.0_darwin_amd64.tar.gz"
      sha256 "10ed0d477faafa3b426ccf2891231f885f140622f8e71d845ad197536e4ae674"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.72.0/crabbox_0.72.0_darwin_arm64.tar.gz"
      sha256 "2bb34a557f89274ccdc186719452dda19038302a6eeeb54029a1e422336d78c2"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.72.0/crabbox_0.72.0_linux_amd64.tar.gz"
      sha256 "aa984d3f0954bafc67eea534c2b2e2a47c3abe90edbe1395a709b451cef1d942"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.72.0/crabbox_0.72.0_linux_arm64.tar.gz"
      sha256 "9e7f04d9869e357c36021bdf1f93783e3ae998979cce95f05ac15340e08c500b"
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
