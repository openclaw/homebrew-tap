# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.83.0/crabbox_0.83.0_darwin_amd64.tar.gz"
      sha256 "a54533e4dd482a40d365641eb2abbede4cf5de05ff8ea747bc6187ee7ff078d5"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.83.0/crabbox_0.83.0_darwin_arm64.tar.gz"
      sha256 "ea2e24f45ff9b4649da90fdd10d2579c6327918605ac7efe2f5003df76a01ffc"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.83.0/crabbox_0.83.0_linux_amd64.tar.gz"
      sha256 "94f3eba5f05e7942796a4604f583ba987e3a2a2f1794fa33f3b5ed6c19f271d6"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.83.0/crabbox_0.83.0_linux_arm64.tar.gz"
      sha256 "3c087cd9f3fbc198b6c09f4897be430c16523d6b126e026770058158aa743149"
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
