class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.16.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.16.0/discrawl_0.16.0_darwin_arm64.tar.gz"
      sha256 "6e17e24890cfa2b46e5d62f578ef37aedf218f12291853b4d95f58074157e334"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.16.0/discrawl_0.16.0_darwin_amd64.tar.gz"
      sha256 "6de21c068dd370513565c6c20c8cd46abe6ef8ef58237dd31ed98cb6f44186c0"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.16.0/discrawl_0.16.0_linux_arm64.tar.gz"
      sha256 "5ddc4ae01e5911c5f9f36fa43a73de180288f1e66f59556f7f0b6c5def3b9b24"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.16.0/discrawl_0.16.0_linux_amd64.tar.gz"
      sha256 "8dbd45991b5ed8d8b79464321401aa6e45208c801a05648df66da59735fc18af"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
