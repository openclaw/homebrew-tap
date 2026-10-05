# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.71.0/crabbox_0.71.0_darwin_amd64.tar.gz"
      sha256 "3b577c16b8c17e7e1b5e0de967fe6380eb12de7a3fc893ac1131bb70050eb3f9"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.71.0/crabbox_0.71.0_darwin_arm64.tar.gz"
      sha256 "96a1c4a469177b407cd831a9bf9b5fc51aa637e0170da0119aa137612190f387"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.71.0/crabbox_0.71.0_linux_amd64.tar.gz"
      sha256 "118c9239a565f1fa1581973ca51f45d173252d219105061c0772d8cd8ff41646"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.71.0/crabbox_0.71.0_linux_arm64.tar.gz"
      sha256 "63a4089e7d04a9165a9718ff98e24a91d2ad2c77416c540f6dbf77b93143526f"
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
