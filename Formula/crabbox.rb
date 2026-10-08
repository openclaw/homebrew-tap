# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.73.0/crabbox_0.73.0_darwin_amd64.tar.gz"
      sha256 "9645d9622707feff0ff18d4b60f6d850a154bddab86b2e568443a634f8d0dcda"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.73.0/crabbox_0.73.0_darwin_arm64.tar.gz"
      sha256 "ae59bf70397d127345456a74e2b2a582ede5476ee3daf78d141478ff2ffd6ff3"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.73.0/crabbox_0.73.0_linux_amd64.tar.gz"
      sha256 "cc46e23e2d49ab9085f9afc7a1d8685c60bee828317cdf537f35c510c3676687"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.73.0/crabbox_0.73.0_linux_arm64.tar.gz"
      sha256 "20e0a7ab8125307175dfe59f76ce8e4f432f8483c6d1eb42a99fa4d982191983"
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
