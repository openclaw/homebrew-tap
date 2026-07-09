class Discrawl < Formula
  desc "Mirror Discord into SQLite and search server history locally"
  homepage "https://github.com/openclaw/discrawl"
  version "0.11.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.5/discrawl_0.11.5_darwin_arm64.tar.gz"
      sha256 "1fc19ebbef766fce56552003059ff905fa1eaa468bd18e12ad766c0a8607767e"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.5/discrawl_0.11.5_darwin_amd64.tar.gz"
      sha256 "b63abe8e977bda5cbbf87671c20bbf6534661b79e3585d7f5886d2de3f72105f"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.5/discrawl_0.11.5_linux_arm64.tar.gz"
      sha256 "2bd6485b7c334cc759df39aab6ac8321ed3a17f9d7129bb21f0cf84881c6a767"
    else
      url "https://github.com/openclaw/discrawl/releases/download/v0.11.5/discrawl_0.11.5_linux_amd64.tar.gz"
      sha256 "b25fc276e03fbd22836c01a95882cadc704920295b9f2eaa385bdfe015c17757"
    end
  end

  def install
    bin.install "discrawl"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/discrawl --version").strip
  end
end
