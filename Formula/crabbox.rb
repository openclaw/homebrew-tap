# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.67.0/crabbox_0.67.0_darwin_amd64.tar.gz"
      sha256 "e15dab410b910dfa059718bb47d9fe061f58ac41693e67cb62fca4cfae0d0692"
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.67.0/crabbox_0.67.0_darwin_arm64.tar.gz"
      sha256 "6309a549c2dc752cb3184f95a847bfe695a4611beda072ebc989e736effc46df"
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.67.0/crabbox_0.67.0_linux_amd64.tar.gz"
      sha256 "1d01ec9d86ce6cd1e1cbae56e779b920ad23e11ccffa48ef7494f94822405b25"
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.67.0/crabbox_0.67.0_linux_arm64.tar.gz"
      sha256 "f0a9b5d9733e0093a98688de85c47d51418ee3228fb00268e6f54a76edf7a746"
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
