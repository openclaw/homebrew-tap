# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.78.1/crabbox_0.78.1_darwin_amd64.tar.gz"
      sha256 "df173b335e86dd5cd03c1e30e38cc007695ab034ff126d1cfaba7d4ece970a22"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.78.1/crabbox_0.78.1_darwin_arm64.tar.gz"
      sha256 "4557be9151d43ea95ae77a4830a0c796e3577d065cdfbd092947deec0eb57b21"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.78.1/crabbox_0.78.1_linux_amd64.tar.gz"
      sha256 "f84913c3963367d3ac3fbf3c5a228941aeab164a6942b30dfe5654c50f8f42d5"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.78.1/crabbox_0.78.1_linux_arm64.tar.gz"
      sha256 "4668d389e920dc2f8cbb16f3db05ddf5b1d864fbe67c307f08c4df27aacdfaad"
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
