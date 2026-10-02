# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.70.0/crabbox_0.70.0_darwin_amd64.tar.gz"
      sha256 "9184ce858f507662c1e97fb164d45ce7d973d50962cc84b1c3c9e1ebe7f71654"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.70.0/crabbox_0.70.0_darwin_arm64.tar.gz"
      sha256 "4f70e5ae4fe16f7f3562b5b4cdf137dadbdfb763ed6ff94404e67e91b9d8ada0"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.70.0/crabbox_0.70.0_linux_amd64.tar.gz"
      sha256 "3fe2cbaf9b6b6573b8416b285fb2eb8755a466b7f1c42a387266fc79304c7892"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.70.0/crabbox_0.70.0_linux_arm64.tar.gz"
      sha256 "75820218b2d7c12c88a3bfa5dd610973577953e529386f7ee84d19ad9d749b85"
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
