class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.7.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.7.3/octopool_0.7.3_darwin_arm64.tar.gz"
      sha256 "faa3cc80b43df1d673720fa5060493ac6767b5619284ec6f4de55ab8a94e9d5f"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.7.3/octopool_0.7.3_darwin_amd64.tar.gz"
      sha256 "e599ab817a4d17aa0429312e7a22f0e134d6ad2f3491ad2510eeca19c25440a9"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.7.3/octopool_0.7.3_linux_arm64.tar.gz"
      sha256 "7f0512bf475120699a27ef97f9d4d357cc7800105cbb9324ffbcd7c29660d59e"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.7.3/octopool_0.7.3_linux_amd64.tar.gz"
      sha256 "66bd97fb783bc3ee1bc15f51f713dafb0be6b7ed62aea2b9180b50410899eda6"
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
