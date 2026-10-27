class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.5.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.5/telecrawl_0.5.5_darwin_arm64.tar.gz"
      sha256 "64d318fd4dfc683cbb0b57e65e8519ae09c00f456afa217d569dfbf7af17aff4"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.5/telecrawl_0.5.5_darwin_amd64.tar.gz"
      sha256 "482855f3a013e5bc094e195d8ed5ba12bb74fd71db39daf98de83dedc4ae9721"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.5/telecrawl_0.5.5_linux_arm64.tar.gz"
      sha256 "0257ac071f54dafecbdf8cdfe2ec60f4210f41af38f26bfb18831805036efc7b"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.5/telecrawl_0.5.5_linux_amd64.tar.gz"
      sha256 "0f9b7ebd8a10e2121e6d14b83124db5c22bc26ee8e32b5b10ae317b2a30a3532"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
