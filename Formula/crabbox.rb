# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.83.2/crabbox_0.83.2_darwin_amd64.tar.gz"
      sha256 "4c2d98c3735160fa71a92ed52a9ebad374c789cf9373646da49a6515d751147d"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.83.2/crabbox_0.83.2_darwin_arm64.tar.gz"
      sha256 "7b00254bc6d3a7e2021fbbd986291a7003173ed876188fc222b9747978314522"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.83.2/crabbox_0.83.2_linux_amd64.tar.gz"
      sha256 "1c4ea628b8aac254ce15000f2192afc2cc152364ea88d520f2b701cca483b5c0"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.83.2/crabbox_0.83.2_linux_arm64.tar.gz"
      sha256 "91153058f42f49e1ed0ee7bcf3aaa2b5d37cd7c30c81cd87b7de309c132a3353"
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
