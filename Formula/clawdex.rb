class Clawdex < Formula
  desc "Local-first address book backed by Markdown"
  homepage "https://github.com/openclaw/clawdex"
  version "0.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.3.1/clawdex_0.3.1_darwin_arm64.tar.gz"
      sha256 "2f7c39d30704d43314cc41febc26d1db9977fb5632510426acba1e1d848da68b"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.3.1/clawdex_0.3.1_darwin_amd64.tar.gz"
      sha256 "4ad5ce30eaaaa856b55016bdd7a2447ca5f69fda588db1ce8eb22861d529327a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.3.1/clawdex_0.3.1_linux_arm64.tar.gz"
      sha256 "8777b9050fa039c61e921d52abf0b54e1183527490abbe9d34f3f58a2eeba930"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.3.1/clawdex_0.3.1_linux_amd64.tar.gz"
      sha256 "e5addd9a9dcdc367b272a46b536d545e9e55517c638b6a486aa14030dda2718b"
    end
  end

  skip_clean "bin/clawdex"

  def install
    bin.install "clawdex"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clawdex --version")
  end
end
