class Clawdex < Formula
  desc "Local-first address book backed by Markdown"
  homepage "https://github.com/openclaw/clawdex"
  version "0.2.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.3/clawdex_0.2.3_darwin_arm64.tar.gz"
      sha256 "0f49a4666b69d5f90e20e5c09c44e8495db46912776a54c38c0fea5e12b8c851"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.3/clawdex_0.2.3_darwin_amd64.tar.gz"
      sha256 "f7081628b33743d18a6fed6bbae80dff2487e63748eff7f1806ebe876726cb0b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.3/clawdex_0.2.3_linux_arm64.tar.gz"
      sha256 "35d47fb8931db24f08fb7af459740527febccc6e22a6c3d2e622805ca03349a4"
    else
      url "https://github.com/openclaw/clawdex/releases/download/v0.2.3/clawdex_0.2.3_linux_amd64.tar.gz"
      sha256 "fa833d9d496cafe289d601e1db54d0c1a6a95cb26714a6c2ffd5acaa9fb2c2bd"
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
