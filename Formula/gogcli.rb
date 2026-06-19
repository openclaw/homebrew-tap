class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.29.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.29.0/gogcli_0.29.0_darwin_arm64.tar.gz"
      sha256 "22d19511bfa444b28110921020e826780913bd0a8580e980ad9f65113b0b8764"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.29.0/gogcli_0.29.0_darwin_amd64.tar.gz"
      sha256 "d86ac3043c344dd6b4395921f8ba8a5e5750f20a7414d72214ae20ae95b16964"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.29.0/gogcli_0.29.0_linux_arm64.tar.gz"
      sha256 "dbac3938ed5d54435453101d5c60ce2d1c2c72feda3b53f4b75a395bc50f09b9"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.29.0/gogcli_0.29.0_linux_amd64.tar.gz"
      sha256 "2001ab8e8e2dfb97916af0df25b273763ec26b49e3c425961e66893ca7d0069f"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
