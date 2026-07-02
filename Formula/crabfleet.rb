class Crabfleet < Formula
  desc "Fleet management CLI for Crabbox workers"
  homepage "https://github.com/openclaw/crabfleet"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_arm64.tar.gz"
      sha256 "f76413f4f873783b66d803171c7a1a5c19c63732b967fbb1a179c93a789b1d51"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_darwin_amd64.tar.gz"
      sha256 "b08ae2bb0abcee3aa3d54025f6e63eb9d00789a2dd0c698656756c041e65322d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_arm64.tar.gz"
      sha256 "79cc2546076e0c1c75b0ebeaa9aeb46c98a2310455eeb88379bf5180e6d2a790"
    else
      url "https://github.com/openclaw/crabfleet/releases/download/v#{version}/crabfleet_#{version}_linux_amd64.tar.gz"
      sha256 "68dfbc880a4bb01b1cab61010c94422d1d26dc5c27a0d8beea8c2d36ab7502ba"
    end
  end

  def install
    bin.install "crabfleet"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/crabfleet --version")
  end
end
