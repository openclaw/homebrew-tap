class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.5.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.2/telecrawl_0.5.2_darwin_arm64.tar.gz"
      sha256 "83a3c535d8a8fb02877934ab6dd703d27671bc6e9d7264b13704b9676817731a"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.2/telecrawl_0.5.2_darwin_amd64.tar.gz"
      sha256 "7d8648392dab537237ece76bd937538df28405b1cc22d4d5835db39138cf28b0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.2/telecrawl_0.5.2_linux_arm64.tar.gz"
      sha256 "b7ffcdc32a1b491252da60d433dc1478844d2cd714182cd48ebdf076e62725f4"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.5.2/telecrawl_0.5.2_linux_amd64.tar.gz"
      sha256 "4f2b4fb331d84d76a17c8340b041a03813bae3b9edec43b8119b53ca00e3953b"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
