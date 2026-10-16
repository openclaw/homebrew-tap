class Goplaces < Formula
  desc "Go client and CLI for the Google Places API (New)"
  homepage "https://github.com/openclaw/goplaces"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.13/goplaces_0.4.13_darwin_arm64.tar.gz"
      sha256 "7f2ac4ee4922d58433eb11f542e471e27b4accf0708338a75fc43de646e4129e"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.13/goplaces_0.4.13_darwin_amd64.tar.gz"
      sha256 "151d0b46aa2fa9ea4387fd3f42684b883ed880f731f30d9ff9f405606f35851d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.13/goplaces_0.4.13_linux_arm64.tar.gz"
      sha256 "e36b309c8cd743e01463ae4f6d88f8622319b32dc55e3817133edc9ea7e252fb"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.13/goplaces_0.4.13_linux_amd64.tar.gz"
      sha256 "7c4bce86797c13ed6fa1e9a0a4dbd68e31dd97beed37e6fa8a142028736ce494"
    end
  end

  def install
    bin.install "goplaces"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goplaces --version")
  end
end
