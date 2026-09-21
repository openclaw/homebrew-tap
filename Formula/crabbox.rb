# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.64.0/crabbox_0.64.0_darwin_amd64.tar.gz"
      sha256 "47b50edd436180f3183039898974964ba8dc9986b73b5f026514ae79d8da4a96"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.64.0/crabbox_0.64.0_darwin_arm64.tar.gz"
      sha256 "0da4ebaf05bfc8fed2632aae57ae6504bee3d23f528fc77587788459d11f307e"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.64.0/crabbox_0.64.0_linux_amd64.tar.gz"
      sha256 "54afb10e9bed2b40a5be306dad2f131fc08676baa212d4da40784ddee7cd2c58"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.64.0/crabbox_0.64.0_linux_arm64.tar.gz"
      sha256 "778f55f3d4f0227eaa49ad752b84cc40b056b803a762d90311d32b87c1dea83f"
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
