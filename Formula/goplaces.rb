class Goplaces < Formula
  desc "Go client and CLI for the Google Places API (New)"
  homepage "https://github.com/openclaw/goplaces"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.12/goplaces_0.4.12_darwin_arm64.tar.gz"
      sha256 "dbba32ea69cd9aad2681d4bee4d240f1257ab601c8c7235fc06db002b0e1e2e4"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.12/goplaces_0.4.12_darwin_amd64.tar.gz"
      sha256 "29057b3054def1bc1feb891330534ae2720263820e0928ac06f2d1a180b65ee3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.12/goplaces_0.4.12_linux_arm64.tar.gz"
      sha256 "053c11b50bfc0ce00a6a07ab317f077a0631d06ca34f6746259e953a783983ef"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.12/goplaces_0.4.12_linux_amd64.tar.gz"
      sha256 "e97dc2261d011dc15586d4684800ea998057860736686e8dfc2789647910cc0e"
    end
  end

  def install
    bin.install "goplaces"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goplaces --version")
  end
end
