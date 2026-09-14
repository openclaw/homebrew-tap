class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.4.0/telecrawl_0.4.0_darwin_arm64.tar.gz"
      sha256 "e4efac20ea9db932c4dd73cfea51f7b0b802abbd04f395799f2aef3618813c30"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.4.0/telecrawl_0.4.0_darwin_amd64.tar.gz"
      sha256 "59d99151be88c626ab25e5df475d2f147300289904abbbd0283e05c9b0526b3d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.4.0/telecrawl_0.4.0_linux_arm64.tar.gz"
      sha256 "dce6cbbe022f60ad36f00979cb75ba9d07ea6ae4a82593658f2befb09bd50175"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.4.0/telecrawl_0.4.0_linux_amd64.tar.gz"
      sha256 "bc23618796dff7f8713731a2d7b1a7b84642e2d62ac6a2be4e99a9060fcd6fe8"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
