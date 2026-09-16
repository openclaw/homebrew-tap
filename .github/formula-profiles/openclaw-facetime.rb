require "zlib"

class OpenclawFacetime < Formula
  desc "Native FaceTime audio and call-control helpers for OpenClaw"
  homepage "https://github.com/openclaw/openclaw-facetime"
  url "https://github.com/openclaw/openclaw-facetime/releases/download/v0.1.1/openclaw-facetime-macos-arm64.zip"
  sha256 "RELEASE_SHA256"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "sox"

  skip_clean "libexec/facetime-audio-capture", "libexec/FaceTimeHelper.dylib"

  def install
    odie "openclaw-facetime requires macOS 14.4 or later" if MacOS.version < "14.4"
    Zlib::GzipWriter.open("FaceTimeHelper.dylib.gz") do |gzip|
      gzip.write File.binread("FaceTimeHelper.dylib")
    end
    libexec.install "facetime-audio-capture"
    libexec.install "FaceTimeHelper.dylib"
    libexec.install "FaceTimeHelper.dylib.gz"
    libexec.install "FaceTimeHelper.build-id"
    libexec.install "VERSION"
    libexec.install "native-protocol.env"
    libexec.install "LICENSE"
    libexec.install "THIRD_PARTY_NOTICES.md"
  end

  post_install_steps do
    install_gzipped_executable "libexec/FaceTimeHelper.dylib.gz",
                               "libexec/FaceTimeHelper.dylib"
  end

  def caveats
    <<~EOS
      This formula installs native helpers consumed by the OpenClaw FaceTime
      plugin and SoX for the host-owned playback process. It does not install or
      enable the plugin itself.

      Install and configure the plugin separately:
        https://docs.openclaw.ai/plugins/facetime

      Call control requires SIP debugging restrictions disabled and Developer
      Tools access enabled. The separately built GPL-derived audio driver is
      intentionally not included in this formula.
    EOS
  end

  test do
    assert_predicate libexec/"facetime-audio-capture", :executable?
    assert_path_exists libexec/"FaceTimeHelper.dylib"
    assert_match(/\A[0-9a-f]{64}\n?\z/, (libexec/"FaceTimeHelper.build-id").read)
    assert_match version.to_s, (libexec/"VERSION").read
    assert_equal "NATIVE_PROTOCOL_VERSION=1\n", (libexec/"native-protocol.env").read
    %w[facetime-audio-capture FaceTimeHelper.dylib].each do |artifact|
      path = libexec/artifact
      system "/usr/bin/codesign", "--verify", "--strict", path
      signature = shell_output("/usr/bin/codesign -dvv #{path} 2>&1")
      assert_match "Authority=Developer ID Application: OpenClaw Foundation (FWJYW4S8P8)", signature
      assert_match "TeamIdentifier=FWJYW4S8P8", signature
    end
  end
end
