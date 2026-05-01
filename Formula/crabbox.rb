# typed: false
# frozen_string_literal: true

class Crabbox < Formula
  desc "Remote Linux test boxes for dirty worktrees and CI hydration"
  homepage "https://github.com/openclaw/crabbox"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.intel?
      url "https://github.com/openclaw/crabbox/releases/download/v0.2.0/crabbox_0.2.0_darwin_amd64.tar.gz"
      sha256 "587ac5f3b9f0f0567160bebe486f1a131611c15493c246f8f6e895df023b01f4"

      define_method(:install) do
        bin.install "crabbox"
      end
    end

    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabbox/releases/download/v0.2.0/crabbox_0.2.0_darwin_arm64.tar.gz"
      sha256 "58fb2958400c32c180aa5c37da47e96fdee0d22e65b13cdc8f3d28616c82e173"

      define_method(:install) do
        bin.install "crabbox"
      end
    end
  end

  on_linux do
    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.2.0/crabbox_0.2.0_linux_amd64.tar.gz"
      sha256 "9ff97d845e1d4a98a915e8e099a159b17d526ee54389adba58ee7a28b6186e74"

      define_method(:install) do
        bin.install "crabbox"
      end
    end

    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/crabbox/releases/download/v0.2.0/crabbox_0.2.0_linux_arm64.tar.gz"
      sha256 "94cbdabfd87257d2025998861b6bd36e3fab2359aacbdc7096b44542086838d0"

      define_method(:install) do
        bin.install "crabbox"
      end
    end
  end

  test do
    system bin/"crabbox", "--version"
  end
end
