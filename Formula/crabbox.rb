# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.66.0/crabbox_0.66.0_darwin_amd64.tar.gz"
      sha256 "cc06ee59c240df51ecde6726ed5d87bcc5b78201c9cdbd3434556048ddd65be4"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.66.0/crabbox_0.66.0_darwin_arm64.tar.gz"
      sha256 "65839102bf4e7a8496528ee20641e4a0ab5cadf139ebacf90809af8926bb15da"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.66.0/crabbox_0.66.0_linux_amd64.tar.gz"
      sha256 "027907f7f2274d0eb15fbeea6583f6f421f2645189e22671ba327f3f961efc9d"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.66.0/crabbox_0.66.0_linux_arm64.tar.gz"
      sha256 "329cfb048374a94c6125e91fc32e0915077c1879b0713cbec7cacbac92d162b7"
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
