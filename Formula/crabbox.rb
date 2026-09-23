# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.65.0/crabbox_0.65.0_darwin_amd64.tar.gz"
      sha256 "3f4ef28da1349c851f161f82643e1e177e2194f8baba4792a12806c71bd64605"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.65.0/crabbox_0.65.0_darwin_arm64.tar.gz"
      sha256 "e0d4029d81ebac82017f0f24f0aca7e15e482e9dd1cc8be026ef76ea62755440"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.65.0/crabbox_0.65.0_linux_amd64.tar.gz"
      sha256 "4306a5c6cbc0bc3787a1db3804c1075800bd3f4b918870c739da82935fd532ee"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.65.0/crabbox_0.65.0_linux_arm64.tar.gz"
      sha256 "4ca6f238bd85064b6d443903af1ade654b93af70536c1478a17f4aa3626d812f"
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
