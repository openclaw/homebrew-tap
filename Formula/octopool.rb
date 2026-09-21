class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.7.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.7.1/octopool_0.7.1_darwin_arm64.tar.gz"
      sha256 "cf0fb8dd79928a12172e1e575af0a3fd338ab836bc83469cebda491c46a279aa"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.7.1/octopool_0.7.1_darwin_amd64.tar.gz"
      sha256 "7c25707fd2cb7c31ed35b93d9481987318f2045c310abf8d3045a4d42d9e7697"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.7.1/octopool_0.7.1_linux_arm64.tar.gz"
      sha256 "a85d915105c8d68dee6b9a07c0a83b9f3fe8bcd61fa61635963fd7aae1f5fcbe"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.7.1/octopool_0.7.1_linux_amd64.tar.gz"
      sha256 "f2e3ecfb9f43bdd84e91d8e5b465d261a1352a2c0adc7f7eb4b4e98dcca6833a"
    end
  end

  def install
    bin.install "octopool"
  end

  def caveats
    <<~EOS
      Run `octopool install-shim` to route gh through Octopool in every zsh.
    EOS
  end

  test do
    assert_match "octopool #{version}", shell_output("#{bin}/octopool version")
  end
end
