# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.0/crabbox_0.79.0_darwin_amd64.tar.gz"
      sha256 "5013669385fedcee0325cee78f6af8a62be50a627dea2dc0bfed0b7cfecbbbc4"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.0/crabbox_0.79.0_darwin_arm64.tar.gz"
      sha256 "6c6e3c1d257e98858ecb97c37dad54b6249ff11747887db844fd3bd410ada5e1"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.0/crabbox_0.79.0_linux_amd64.tar.gz"
      sha256 "fc4d8d04b1a596e8e5fdc6af7b0794d44f3f19c2f63153205b92d45ebc5f095b"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.0/crabbox_0.79.0_linux_arm64.tar.gz"
      sha256 "f950990700bda55851233c185c2397dc978a2576b113ff5567962e5387d6dd31"
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
