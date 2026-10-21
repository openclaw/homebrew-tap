class Clawdex < Formula
  desc "Local-first address book backed by Markdown"
  homepage "https://github.com/openclaw/clawdex"
  version "0.4.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.1/clawdex_0.4.1_darwin_arm64.tar.gz"
      sha256 "6b2f54ea3f53502f3302d64ab1d39805ffa8e11640769ac5851a1bcfede2fb7c"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.1/clawdex_0.4.1_darwin_amd64.tar.gz"
      sha256 "c4e7238116e3f1d2374b34ca4dc8cc536e4337524017f617b2a0a8e770f5f705"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.1/clawdex_0.4.1_linux_arm64.tar.gz"
      sha256 "214a2fcda5d886ead59638df44fedd98c9784e9cac4e6e12fa7cd5481ff2fe6b"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.4.1/clawdex_0.4.1_linux_amd64.tar.gz"
      sha256 "af73b820171529885a812ac17ccad1d6254976a24e4606e58ce4c26b66c16fd6"
    end
  end

  skip_clean "bin/clawdex"

  def install
    bin.install "clawdex"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawdex --version")
  end
end
