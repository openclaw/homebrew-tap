# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.69.0/crabbox_0.69.0_darwin_amd64.tar.gz"
      sha256 "66784581293c90470848570bdca63a7cb5e0246cc2e60a581a80137a09f413bb"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.69.0/crabbox_0.69.0_darwin_arm64.tar.gz"
      sha256 "033f85b1e7e4262603d845303b30fff8145e53f62aaab6a9f4e008ba862b53f6"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.69.0/crabbox_0.69.0_linux_amd64.tar.gz"
      sha256 "153a30025f09df4a554b42177f69c3c8de1e4a27a5c6fc34d32ffacef6b9de85"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.69.0/crabbox_0.69.0_linux_arm64.tar.gz"
      sha256 "768602d793a183354ad5a55a02133d2935bbe4d3d50112ed30343770e5670a66"
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
