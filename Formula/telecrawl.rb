class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.5.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.3/telecrawl_0.5.3_darwin_arm64.tar.gz"
      sha256 "e7296d67359d25f4bcbb32233aadf5e4b9e16996db14dff0688cca1121f28f94"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.3/telecrawl_0.5.3_darwin_amd64.tar.gz"
      sha256 "841f0a0c8fbcd897e6d5bfeb147047355ad1e18ba6a6f37a9b0b86f1feb71fc9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.3/telecrawl_0.5.3_linux_arm64.tar.gz"
      sha256 "f36267d85162ee9df54c8d052c8d0900febe687dbc7f632472f269a3184f43f2"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.3/telecrawl_0.5.3_linux_amd64.tar.gz"
      sha256 "0ad0fbd9bf839b3282081938594c4b792f2d3b423c4d73a3885ddc21db9be789"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
