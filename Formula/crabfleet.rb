class Crabfleet < Formula
  desc "Crabfleet crabbox CLI"
  homepage "https://github.com/openclaw/crabfleet"
  version "0.2.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_arm64.tar.gz"
      sha256 "0b2bfd228fedac6c63653935136cd5abe42746f1ba48b2c690cc555fa7de6b3c"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_amd64.tar.gz"
      sha256 "c40e9f480e353a8b1195e56ade5b6d1305e50c89398d884992bc0e82b1c82407"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_arm64.tar.gz"
      sha256 "3e55019b894e0a619a7301273a9287cae7296d14a32de6a9bd9cecee12031509"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_amd64.tar.gz"
      sha256 "a7042c7b357a4b05e2e20d7d5b3e60c95438166be4e4cb57281c780f171912fd"
    end
  end

  def install
    bin.install "crabfleet"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/crabfleet --version")
  end
end
