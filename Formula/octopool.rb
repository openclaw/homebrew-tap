class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.2.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_arm64.tar.gz"
      sha256 "74f40d00bac0279ddf9fb26a15abcc3a389045ada7645eeeea2b8987c480e8dd"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_amd64.tar.gz"
      sha256 "a119d0886b419957d874c438d6033e595a40b282254238b5d5c56413cb023346"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_arm64.tar.gz"
      sha256 "ccc13d98e1b35b47e48321db1a7c527cd21d134a6811c4e2bbaa6e224a861d2d"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_amd64.tar.gz"
      sha256 "1467057b7fb4783f1cbde7323dce818343ba6a7ccf0ff5323d89665d568b4b56"
    end
  end

  def install
    bin.install "octopool"
  end

  def caveats
    <<~EOS
      To use the GitHub CLI shim, symlink the same binary as gh
      and set OCTOPOOL_GH_PATH to the real GitHub CLI if needed.
    EOS
  end

  test do
    assert_match "octopool #{version}", shell_output("#{bin}/octopool version")
  end
end
