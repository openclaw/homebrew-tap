# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.77.0/crabbox_0.77.0_darwin_amd64.tar.gz"
      sha256 "59a3eef666b7cb32ed7b64cca6b548998dad53fee7bf02acbf11b67c63815e15"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.77.0/crabbox_0.77.0_darwin_arm64.tar.gz"
      sha256 "9f439e655c98c3e0b339a9b0bdbce356bf2570a831db50b4744f4b964171adfb"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.77.0/crabbox_0.77.0_linux_amd64.tar.gz"
      sha256 "cbf6cb74251a454c65d13d7a92b070cf8c37ee81c300c97123063b9d21206d5f"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.77.0/crabbox_0.77.0_linux_arm64.tar.gz"
      sha256 "dc4b4ff1e0df7546bab41b36704a939d78d0f44235b7b222d7ef119b8314a2f4"
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
