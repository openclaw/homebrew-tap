class Octopool < Formula
  desc "Org-authenticated GitHub read relay and cache"
  homepage "https://github.com/openclaw/octopool"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_arm64.tar.gz"
      sha256 "1d48c416fbfa45abfa3d46b71237a63e90a4cd150aa843c45bdf986956bd174f"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_amd64.tar.gz"
      sha256 "f8eaad9aaf7948a126d355b2f2f5db5252d4883e6110be4b98dab01dd001f7e1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_arm64.tar.gz"
      sha256 "43f25b2c8044a2bad8efa6698bffaceaf14191982f4a4d6491c665d6aecf2dce"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_amd64.tar.gz"
      sha256 "5d1538b6b215e75561c336b6d792982629a007c9f8e418a145d6ab95842aeaf5"
    end
  end

  def install
    bin.install "octopool"
  end

  test do
    assert_match "octopool #{version}", shell_output("#{bin}/octopool version")
  end
end
