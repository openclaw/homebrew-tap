# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.74.0/crabbox_0.74.0_darwin_amd64.tar.gz"
      sha256 "fd7c667d2bdd383c73386fd3eaaee6a243b04527e672f6bd4eaa947eca9e8588"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.74.0/crabbox_0.74.0_darwin_arm64.tar.gz"
      sha256 "fdab629f0e58698249cc868476927568f1d54e0f29e94e62683f83e96f19fb77"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.74.0/crabbox_0.74.0_linux_amd64.tar.gz"
      sha256 "ca807ed4f03a4b1cb744f11a6508fce372d2de0061da3511861c14954b692400"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.74.0/crabbox_0.74.0_linux_arm64.tar.gz"
      sha256 "128a30a83ab8c9491568b6b5392623033471a5d5654ee3c9141a1d3cbcf80395"
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
