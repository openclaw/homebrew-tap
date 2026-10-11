class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.7/discrawl_0.15.7_darwin_arm64.tar.gz"
      sha256 "c0bba57d796f2e0c1b17010f12ee4cf3f61c351e36dc269a2aa65346a3c75616"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.7/discrawl_0.15.7_darwin_amd64.tar.gz"
      sha256 "5d0f2e3f9b1c480d604f54f5ae00b6c24d4bd82e798ac4288af9c34b30f87712"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.7/discrawl_0.15.7_linux_arm64.tar.gz"
      sha256 "dcfa1e3e7c815c8483fb42baa2da055076216614830a4a418635834df63421f6"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.7/discrawl_0.15.7_linux_amd64.tar.gz"
      sha256 "99225427a451f027c4d82fcab88a7b5e4cf362a434cd9acad0cf71d505cec4f1"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
