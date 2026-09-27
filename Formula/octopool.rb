class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.0/octopool_0.9.0_darwin_arm64.tar.gz"
      sha256 "a2b7786aa6cc03a9d7911a41bbd8bcc579ffc9f179d15a616c788f66354000d6"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.0/octopool_0.9.0_darwin_amd64.tar.gz"
      sha256 "1f052cf3e153ff1de1d3993e21fa99060f05ebea5942aacbce38096b68b567fc"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.0/octopool_0.9.0_linux_arm64.tar.gz"
      sha256 "b6d93098e28d9b6835576253e2ace6ad102bb9c34147a42d86054671c646e0b0"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.0/octopool_0.9.0_linux_amd64.tar.gz"
      sha256 "688aa92c4de45b398eb52af80daba0a40a963362b48cf3cb48c871d9207c4479"
    end
  end

  def install
    bin.install "octopool"
  end

  def caveats
    <<~EOS
      Run `octopool install-shim` to route gh through Octopool in every zsh.
    EOS
  end

  test do
    assert_match "octopool #{version}", shell_output("#{bin}/octopool version")
  end
end
