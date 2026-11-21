# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.84.0/crabbox_0.84.0_darwin_amd64.tar.gz"
      sha256 "148721bc76eca176c4a98797d988596856b59d36c2a6ae0a06eb6b26427a9449"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.84.0/crabbox_0.84.0_darwin_arm64.tar.gz"
      sha256 "e79ebf77f2c7267a918fc238e67d9bcf5fc1d8a5ab72d677ccc8228cde430986"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.84.0/crabbox_0.84.0_linux_amd64.tar.gz"
      sha256 "1f1ca73ad99bf0baa2abbd02edd8862a9ce7686d062402c3675fc7beed57fdbc"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.84.0/crabbox_0.84.0_linux_arm64.tar.gz"
      sha256 "26a49799d0fd5100373ab163af5e55fba0a0b3df263b339104e272dbdad148f8"
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
