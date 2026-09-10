# typed: false
# frozen_string_literal: true

# Maintained in this tap; the ordinary updater preserves install behavior.
class Crabbox < Formula
  desc "Remote software testing and execution"
  homepage "https://github.com/openclaw/crabbox"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.55.0/crabbox_0.55.0_darwin_amd64.tar.gz"
      sha256 "607d62adda808be29bb9341071b5e7a895f4f1f45a7905d763870b91f56d3b57"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.55.0/crabbox_0.55.0_darwin_arm64.tar.gz"
      sha256 "5c7c8faf98eb91d64b86b22f859735ae13777c8bdf759e0bd51f9456df5d018e"

      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.55.0/crabbox_0.55.0_linux_amd64.tar.gz"
      sha256 "883e9201c4b508077f092ea3ded99092ea34068e19e9d4dd4812cf50d2134e98"
      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.55.0/crabbox_0.55.0_linux_arm64.tar.gz"
      sha256 "87711d0002f0a4d034f8a651052ea4244fdcc401aed5fd69759d966953d7c4fa"
      define_method(:install) do
        bin.install "crabbox"
        bin.install "crabbox-apple-vm-helper" if OS.mac? && Hardware::CPU.arm?
      end
    end
  end

  test do
    system bin/"crabbox", "--version"
  end
end
