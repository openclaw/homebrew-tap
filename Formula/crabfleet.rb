class Crabfleet < Formula
  desc "Crabfleet crabbox CLI"
  homepage "https://github.com/openclaw/crabfleet"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_arm64.tar.gz"
      sha256 "d91c93cc629e0b19db7f7640ffef67b66dab8f3c92ff3f8f051ec2cbdb1237fb"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_amd64.tar.gz"
      sha256 "bb496f04bf2c007595e959ebe8d6b55b232fa6220beb0f197379dadf2fee2e05"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_arm64.tar.gz"
      sha256 "1d6a31b3547c96464a127f501d7c275169e2575dcfa7f5b7a8ca71617c79dbb8"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_amd64.tar.gz"
      sha256 "fc7dbae93e0d87b952763a35a0347624b6356f1af61a8a5a679f9c66e66d7cdc"
    end
  end

  def install
    bin.install "crabfleet"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/crabfleet --version")
  end
end
