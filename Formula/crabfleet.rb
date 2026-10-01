class Crabfleet < Formula
  desc "Fleet management CLI for Crabbox workers"
  homepage "https://github.com/openclaw/crabfleet"
  version "0.3.1"
  license "MIT"

  livecheck do
    skip "The fleet-management CLI was retired in v0.4.0; later releases ship a separate Linux desktop connector"
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_arm64.tar.gz"
      sha256 "7eae01c94c918dc5d26a386a16d31cc5861f94c42b038368ad032d94129a1552"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_amd64.tar.gz"
      sha256 "0874fd96baf310d77dd4c4b15697a3665498d2eb56e102edccffb9151c2f0c1e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_arm64.tar.gz"
      sha256 "8306fe50c02daddd880ca46c1f887a1110d34ddf8b4668952649b8bb6c778a0a"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_amd64.tar.gz"
      sha256 "e8ca5e6ebf7d0ce2155753c29f8b0de90cb0f4d31f8d7b217eaebbb9788fcf18"
    end
  end

  def install
    bin.install "crabfleet"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/crabfleet --version")
  end
end
