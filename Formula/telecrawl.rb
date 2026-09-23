class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.4.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.4.1/telecrawl_0.4.1_darwin_arm64.tar.gz"
      sha256 "8a170ecd7b3296e402ddfb26aa6f56790066f919dce404ea2d8c8c2e348f4dd3"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.4.1/telecrawl_0.4.1_darwin_amd64.tar.gz"
      sha256 "a194052e5df9d50974d9ccd29abf7930609f5599a8e5f79bc06b5675079977b2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.4.1/telecrawl_0.4.1_linux_arm64.tar.gz"
      sha256 "674c052f9e732fd91aa50cc86ce94e304c0369342c817c5f23ffaca7829d6ede"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.4.1/telecrawl_0.4.1_linux_amd64.tar.gz"
      sha256 "ba78d3a205043e66f2824fa9a4567a0a9bb3ba319ebe09d600bd505c5a94e802"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
