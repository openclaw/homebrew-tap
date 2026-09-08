class Telecrawl < Formula
  desc "Telegram Desktop archive CLI with encrypted Git backups"
  homepage "https://github.com/openclaw/telecrawl"
  version "0.3.7"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.3.7/telecrawl_0.3.7_darwin_arm64.tar.gz"
      sha256 "0b8d8266215cbad5276d7e0a739ce2affdd6820508ea746264c017681df0be5b"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.3.7/telecrawl_0.3.7_darwin_amd64.tar.gz"
      sha256 "cb79d1bc62075333607934fec483eacdab054ac169caa7a80cd5977e25750950"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/telecrawl/releases/download/v0.3.7/telecrawl_0.3.7_linux_arm64.tar.gz"
      sha256 "7cea526c452c4c5d4da28e8acaeec60b9c11914aa305fe962ca1e70de8fa4084"
    else
      url "https://github.com/openclaw/telecrawl/releases/download/v0.3.7/telecrawl_0.3.7_linux_amd64.tar.gz"
      sha256 "580bb2aed190c699048da367301de398e39b7b2f7e28db402b324fb3d0b6280b"
    end
  end

  def install
    bin.install "telecrawl"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/telecrawl --version")
  end
end
