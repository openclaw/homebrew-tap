# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.80.0/crabbox_0.80.0_darwin_amd64.tar.gz"
      sha256 "a36814f7fd2263d69c6bb4d1b7e6d6c2fe12335414634fdcf9e3890d6d7fe850"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.80.0/crabbox_0.80.0_darwin_arm64.tar.gz"
      sha256 "f56af3af140c117821b22d5eb6a59e4710a5a8a8eab1bec357b9abe8228c3c54"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.80.0/crabbox_0.80.0_linux_amd64.tar.gz"
      sha256 "0d2473c651a66c2f08d5df42a23209d8f384ec1bcf64130bc8c9a41efa885374"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.80.0/crabbox_0.80.0_linux_arm64.tar.gz"
      sha256 "cc78799aca1268bb04aae6e4af593ae65eb9b45dc86f4b07da2f0f962d9e9300"
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
