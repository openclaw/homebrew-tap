class Goplaces < Formula
  desc "Go client and CLI for the Google Places API (New)"
  homepage "https://github.com/openclaw/goplaces"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.11/goplaces_0.4.11_darwin_arm64.tar.gz"
      sha256 "9387896c81aec4706510efd60dd958fbdf5056e6a968dddea10ad4f972394028"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.11/goplaces_0.4.11_darwin_amd64.tar.gz"
      sha256 "5ae1940f2b1724a353a07166410defda42c076ac1e8f8284c81dede9295e4ac5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.11/goplaces_0.4.11_linux_arm64.tar.gz"
      sha256 "45fc24ed00d893eef2187ebff63e1593fcb21cb82a093b7aeecd78db2e21a5a7"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.4.11/goplaces_0.4.11_linux_amd64.tar.gz"
      sha256 "a0b6a300769e532102a2f652fa29813a26c45608ea40d836fd97ead8cb25e65a"
    end
  end

  def install
    bin.install "goplaces"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goplaces --version")
  end
end
