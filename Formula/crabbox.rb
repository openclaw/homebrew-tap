# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.62.0/crabbox_0.62.0_darwin_amd64.tar.gz"
      sha256 "90fcfee7d1137ce69b75bd583ed521e511ac0a145ae7b0d5a94480617e62b121"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.62.0/crabbox_0.62.0_darwin_arm64.tar.gz"
      sha256 "7e742950103248c976b429c3ceab6fc6c37e091c96cfd47b473c29565f68f2dc"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.62.0/crabbox_0.62.0_linux_amd64.tar.gz"
      sha256 "efd9e9ee90c804db923fca886b04a2196ffb35c12924e89b03fa1f2442405fa4"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.62.0/crabbox_0.62.0_linux_arm64.tar.gz"
      sha256 "caa7a932c4cbdd0786047b66feebbecce187e341f8e6d3bf59775767b30e42d3"
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
