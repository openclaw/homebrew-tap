class Goplaces < Formula
  desc "Go client and CLI for the Google Places API (New)"
  homepage "https://github.com/openclaw/goplaces"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.5.0/goplaces_0.5.0_darwin_arm64.tar.gz"
      sha256 "9c39b7d62d8fc53a6d178a39e9fc53d3684f04326996308b68b39ba87422a4e7"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.5.0/goplaces_0.5.0_darwin_amd64.tar.gz"
      sha256 "97034c53883ec022dec53eff1e6940073b284fcd2624db30bb4209e96f135aef"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/goplaces/releases/download/v0.5.0/goplaces_0.5.0_linux_arm64.tar.gz"
      sha256 "132e51e5cd6241bfd519567e1dcb376dffb3de83288a736894a48fa1987a4d6a"
    else
      url "https://github.com/openclaw/goplaces/releases/download/v0.5.0/goplaces_0.5.0_linux_amd64.tar.gz"
      sha256 "42dd360021c0c273f180fadbbf3690aae036c76b87b34178582d07196863c2a2"
    end
  end

  def install
    bin.install "goplaces"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/goplaces --version")
  end
end
