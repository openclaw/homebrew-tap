class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.9.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.1/octopool_0.9.1_darwin_arm64.tar.gz"
      sha256 "ea161308867b999cfb761c029353b15e5d921730cf72d2189e3412fe50c66816"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.1/octopool_0.9.1_darwin_amd64.tar.gz"
      sha256 "16526f6c29becf48deb65b2ab926d3c5fe6073db5930b97a7a8253dc391b7f7a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.9.1/octopool_0.9.1_linux_arm64.tar.gz"
      sha256 "5f4689930d13d574457858b0d2b2ac5bc25c00070b14cbd054fccba8af1bbe29"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.9.1/octopool_0.9.1_linux_amd64.tar.gz"
      sha256 "11b85e5617c7fe4762742d9873b8e617810f7c063dc397f6cc83e92a845a412d"
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
