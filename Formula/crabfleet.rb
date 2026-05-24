class Crabfleet < Formula
  desc "Crabfleet crabbox CLI"
  homepage "https://github.com/openclaw/crabfleet"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_arm64.tar.gz"
      sha256 "b5fbbc0724f1865a6b4ae13a02ab3a489226e5ac7be180a5b56439b359c712c0"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_amd64.tar.gz"
      sha256 "47967f60a5d2b02c1963290b8ef7311ac4f85df77b506c96c6aa601ff43eee61"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_arm64.tar.gz"
      sha256 "9e95912e93d09cda1c0c6c805448797e2f065d2ae49bb49ec51212a9c30f30d4"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_amd64.tar.gz"
      sha256 "5707b9b296751af90f0e31d8d9ceb5586b4b30b9259984d2a8073e49d9dce8e2"
    end
  end

  def install
    bin.install "crabfleet"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/crabfleet --version")
  end
end
