class Slacrawl < Formula
  desc "Go-based CLI for mirroring Slack workspace data into local SQLite"
  homepage "https://github.com/openclaw/slacrawl"
  version "0.7.8"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.8/slacrawl_0.7.8_darwin_arm64.tar.gz"
      sha256 "ce97a384d57c65664ef108f0b14042a153c1c23b3bf82c7b0e8ccc6f24906329"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.8/slacrawl_0.7.8_darwin_amd64.tar.gz"
      sha256 "be2948b468d49e95a4d5201dc26070cbd67ce2dacd8f8d28cd055a4593e90672"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.8/slacrawl_0.7.8_linux_arm64.tar.gz"
      sha256 "b5223c348ae6fa8b4dac144366c8766a4e0bc52c7491468400701c7a56da0436"
    else
      url "https://github.com/openclaw/slacrawl/releases/download/v0.7.8/slacrawl_0.7.8_linux_amd64.tar.gz"
      sha256 "1ad5b0e960b345e42c69b8cbdb9c65d7fce871c57c6c456d91fc0e21090f0f3c"
    end
  end

  def install
    bin.install "slacrawl"
  end

  test do
    assert_match "Usage of slacrawl:", shell_output("#{bin}/slacrawl --help")
  end
end
