class Gogcli < Formula
  desc "Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more"
  homepage "https://github.com/openclaw/gogcli"
  version "0.22.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.22.0/gogcli_0.22.0_darwin_arm64.tar.gz"
      sha256 "41b0a62404e5a1c70cb817da313cf13a5770d0b19214928b7ee9dccaeadb0d68"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.22.0/gogcli_0.22.0_darwin_amd64.tar.gz"
      sha256 "2868cf1ce17f6314a66a3e8e550d50b3e2faba0e278b220c9f4577ba2d4457f6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/gogcli/releases/download/v0.22.0/gogcli_0.22.0_linux_arm64.tar.gz"
      sha256 "f46a167cb06e4a9658f674e34086c38456f36c94c6d69ccc94294efdce2b0db6"
    else
      url "https://github.com/openclaw/gogcli/releases/download/v0.22.0/gogcli_0.22.0_linux_amd64.tar.gz"
      sha256 "535be211bd35c94bb1be5f6e98f40eae6ce51fc91da845de1bef6d669c84690f"
    end
  end

  def install
    bin.install "gog"
  end

  test do
    assert_match "Google CLI", shell_output("#{bin}/gog --help")
  end
end
