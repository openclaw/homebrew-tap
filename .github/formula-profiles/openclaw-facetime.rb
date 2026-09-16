class OpenclawFacetime < Formula
  desc "Native FaceTime audio and call-control helpers for OpenClaw"
  homepage "https://github.com/openclaw/openclaw-facetime"
  url "https://github.com/openclaw/openclaw-facetime/releases/download/v0.1.0/openclaw-facetime-macos-arm64.zip"
  sha256 "RELEASE_SHA256"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on "sox"

  skip_clean "libexec/facetime-audio-capture", "libexec/FaceTimeHelper.dylib"

  def install
    odie "openclaw-facetime requires macOS 14.4 or later" if MacOS.version < "14.4"
    libexec.install "facetime-audio-capture"
    libexec.install "FaceTimeHelper.dylib"
    libexec.install "FaceTimeHelper.build-id"
    libexec.install "VERSION"
    libexec.install "native-protocol.env"
    libexec.install "LICENSE"
    libexec.install "THIRD_PARTY_NOTICES.md"
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
    system "/usr/bin/codesign", "--verify", "--strict", "--check-notarization",
           "-R=notarized", libexec/"facetime-audio-capture"
    system "/usr/bin/codesign", "--verify", "--strict", "--check-notarization",
           "-R=notarized", libexec/"FaceTimeHelper.dylib"
  end
end
