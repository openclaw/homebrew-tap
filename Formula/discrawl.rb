class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.9.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.9.0/discrawl_0.9.0_darwin_arm64.tar.gz"
      sha256 "07a01692d1622175f9b8ba12563752b2d9a60ec2b0b0afca7b6cdbec3b025c16"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.9.0/discrawl_0.9.0_darwin_amd64.tar.gz"
      sha256 "56c50f258b2402915d00b1973497bf830af262ce35b4b4016745f0456b0481b4"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.9.0/discrawl_0.9.0_linux_arm64.tar.gz"
      sha256 "713205fcdfbcec22b4cb197a5acab2736b1621e90e2470ab03f25845ed906fc2"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.9.0/discrawl_0.9.0_linux_amd64.tar.gz"
      sha256 "84834c060f6bc8d8219e3f89b2e1945a60e393fd206ee27fe74a85b3f1cdc17b"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
