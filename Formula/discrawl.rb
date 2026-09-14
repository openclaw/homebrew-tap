class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.15.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.1/discrawl_0.15.1_darwin_arm64.tar.gz"
      sha256 "2affb13d2d36d99b7d27d8d71c5822da1e1b924271fd9be4c8736612ab9428e4"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.1/discrawl_0.15.1_darwin_amd64.tar.gz"
      sha256 "577a9dede9db125897cf6f72eb9345a4ab43d2f06eb9d594479cc04ee89ba9db"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.1/discrawl_0.15.1_linux_arm64.tar.gz"
      sha256 "03d38b3a625c847e3bfd1c876dd6ff072b1f3173d4929be5d2ecef7f3f655ba7"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.15.1/discrawl_0.15.1_linux_amd64.tar.gz"
      sha256 "a457931d4eea0bb8a679c5706669a9f3fd874e2fe853e0fd3d77dc7b7d843487"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
