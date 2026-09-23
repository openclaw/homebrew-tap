class Octopool < Formula
  desc "Org-authenticated GitHub read relay and gh-compatible cache shim"
  homepage "https://github.com/openclaw/octopool"
  version "0.7.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/octopool/releases/download/v0.7.2/octopool_0.7.2_darwin_arm64.tar.gz"
      sha256 "70538bec076c520e464b127bd13ebe79bf7faa7339e2ec68a3102bb745de457e"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.7.2/octopool_0.7.2_darwin_amd64.tar.gz"
      sha256 "6a865c7a463b87ade5b3d6f8e1470b0ed74dc8459611600dc918784131b4ba53"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/octopool/releases/download/v0.7.2/octopool_0.7.2_linux_arm64.tar.gz"
      sha256 "cd56f07fea48dc07704f8248af8edc34bb8407a7872450b4fb865ba6247154d0"
    else
      url "https://github.com/openclaw/octopool/releases/download/v0.7.2/octopool_0.7.2_linux_amd64.tar.gz"
      sha256 "f24686a1b829fbdd4ae3723de7aacfe1ebf51767d85d011e183621a4c36a5e7a"
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
