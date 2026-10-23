class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.5.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.4/telecrawl_0.5.4_darwin_arm64.tar.gz"
      sha256 "5555a041d29d8ed0f38fef150483b27153636969a065a33dae6cb7b1545fec06"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.4/telecrawl_0.5.4_darwin_amd64.tar.gz"
      sha256 "689d08e78d0a4e9c6f61354177af2e9a0383488d0ac4d3efe79badaa94375143"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.4/telecrawl_0.5.4_linux_arm64.tar.gz"
      sha256 "8fc37c6cc2dcf864066f2f5b8823b587d61be8335a04cf005136e4d4af97f3fa"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.4/telecrawl_0.5.4_linux_amd64.tar.gz"
      sha256 "07b47a770d96ddade3d0a5beb8292561d5d35e3507b4387a6268c0e902dcd273"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
