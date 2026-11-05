# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.82.0/crabbox_0.82.0_darwin_amd64.tar.gz"
      sha256 "2d2bfffd5aa68f37b76d4284cf9f12c739b8e378352a029dc8b9955d80f3c639"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.82.0/crabbox_0.82.0_darwin_arm64.tar.gz"
      sha256 "bac0a7bddc2468dd6a52ba7532aef83ccab19805ba4751b3dc4021f39cb91977"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.82.0/crabbox_0.82.0_linux_amd64.tar.gz"
      sha256 "694db564eab583b52e0a9b67b386e664f18ed81eb8a070ef118503b2c68c0169"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.82.0/crabbox_0.82.0_linux_arm64.tar.gz"
      sha256 "ba266dcb60cbc3c41994f7ddf8033b1b3fe1018cbabdf25cdb912b4c7876787e"
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
