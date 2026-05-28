class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_arm64.tar.gz"
      sha256 "f0291162ec2972bec8a6ae6c3e376a3b5be18a107107b64c20e69cb08b36709d"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_darwin_amd64.tar.gz"
      sha256 "7ec78c647a9fcdd5ab07fc8fe94d86e89d8563d03ea4399c7f6bbce4e127dda6"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_arm64.tar.gz"
      sha256 "8ebfac56a2c5bbb107e9daae6edf12fb560eb97c5ebcf6ff0e017d0c02181a49"
    else
      url "https://github.com/openclaw/octopool/releases/download/v#{version}/octopool_#{version}_linux_amd64.tar.gz"
      sha256 "ab28f1f116f050075308f599383359f125fccbd4fc0726a5f78678e98cbf7cd3"
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
