class Axorc < Formula
  desc "Inspect and automate macOS Accessibility from the shell"
  homepage "https://github.com/openclaw/AXorcist"
  url on_arch_conditional(
    arm:   "https://github.com/openclaw/AXorcist/releases/download/v0.2.2/axorc-0.2.2-macos-arm64.zip",
    intel: "https://github.com/openclaw/AXorcist/releases/download/v0.2.2/axorc-0.2.2-macos-x86_64.zip",
  )
  sha256 on_arch_conditional(
    arm:   "50a5df9dd457d292ba5b1c73329ae0452f727c5abff2625434072d0e3ea2fe54",
    intel: "72280da6e4a7cc1ad5e3942e88513614057fb12cf96435123e3663ca817a5e59",
  )
  license "MIT"

  depends_on macos: :sonoma

  skip_clean "bin/axorc"

  def install
    bin.install "axorc"
  end

  def caveats
    <<~EOS
      axorc requires Accessibility permission:
        System Settings > Privacy & Security > Accessibility
    EOS
  end

  test do
    assert_match "axorc #{version}", shell_output("#{bin}/axorc --version")
    assert_match "USAGE:", shell_output("#{bin}/axorc --help")
    assert_equal [Hardware::CPU.arm? ? "arm64" : "x86_64"],
                 shell_output("/usr/bin/lipo -archs #{bin}/axorc").split.sort
    system "/usr/bin/codesign", "--verify", "--strict", bin/"axorc"
    assert_match "anchor apple generic", shell_output("/usr/bin/codesign -d -r- #{bin}/axorc 2>&1")
  end
end
