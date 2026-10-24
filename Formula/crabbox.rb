# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.3/crabbox_0.79.3_darwin_amd64.tar.gz"
      sha256 "8264c513f02a09095c273cee969ffb94b9e73e9ece377ae39bcecb85e4b36fa2"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.3/crabbox_0.79.3_darwin_arm64.tar.gz"
      sha256 "a11fc0e5a468cf01ec3dad27f57dd6bddf0ec40913edc66d48822f1d7b3b262a"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.3/crabbox_0.79.3_linux_amd64.tar.gz"
      sha256 "0dae99ecebf779eecd66ff4922fb67bb99e1f50409ab3585722f4f6f6aa0f6d6"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.79.3/crabbox_0.79.3_linux_arm64.tar.gz"
      sha256 "eec44536e3fa186e49784606e78826bf30c2e7bd2e125a64b0ea616b11f8407d"
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
