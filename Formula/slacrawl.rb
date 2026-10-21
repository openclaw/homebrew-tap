class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.10.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.4/slacrawl_0.10.4_darwin_arm64.tar.gz"
      sha256 "a438b4570b880270d9a34721e8c47e84762f1d61df1fc156aa95b992982e517f"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.4/slacrawl_0.10.4_darwin_amd64.tar.gz"
      sha256 "1a5ee73e75f8aa59a946a20e0bc774fdf5ada9757feead91798e2655876d2896"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.4/slacrawl_0.10.4_linux_arm64.tar.gz"
      sha256 "352e7e4365836c888b711067aa44b43966e0b872d852f189211bebada41b1ac9"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.10.4/slacrawl_0.10.4_linux_amd64.tar.gz"
      sha256 "57e5e20c0b9b38f125f5f38985cf2107d07fc86cef9ca2dc2679d5ac0b1e24c2"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
