# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.1/crabbox_0.79.1_darwin_amd64.tar.gz"
      sha256 "45e0adfad29b8e84dd28eb6520f3f495d852c0b140065bb0ded7d428f6789c35"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.1/crabbox_0.79.1_darwin_arm64.tar.gz"
      sha256 "32af6c1c53dbe41ee705e428561752472cc2e4b6bd5ff7e3f019e8021c0ee515"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.1/crabbox_0.79.1_linux_amd64.tar.gz"
      sha256 "783d8be14a0ac70599ac0b4fa6ab3a587b70b043b77c925c1670fb4e4a8c955f"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.1/crabbox_0.79.1_linux_arm64.tar.gz"
      sha256 "d110aa7504c6e5207ee3ac8c788de83fada531d2aaf4c1100fdde031bec82c1c"
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
