# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.81.0/crabbox_0.81.0_darwin_amd64.tar.gz"
      sha256 "667c2711f677d52d5e39df65c2031592022f55de77ee223bb98115e67f1af7ab"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.81.0/crabbox_0.81.0_darwin_arm64.tar.gz"
      sha256 "45dee34bb593d28774c5ca30150165d5fc48ab5759886499cabb977f3bff4751"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.81.0/crabbox_0.81.0_linux_amd64.tar.gz"
      sha256 "1d25267b161c1ac6c12c15cd7c4cb96a49a8c1622d365fb932f3ef3bd3123d33"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.81.0/crabbox_0.81.0_linux_arm64.tar.gz"
      sha256 "2d8bc489850483b7b99a3727705b1ec66ad38db9c231929769fc60af07a1d2c7"
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
