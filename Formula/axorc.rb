class Axorc < Formula
  desc "Inspect and automate macOS Accessibility from the shell"
  homepage "https://github.com/openclaw/AXorcist"
  url on_arch_conditional(
    arm:   "https://github.com/openclaw/AXorcist/releases/download/v0.2.3/axorc-0.2.3-macos-arm64.zip",
    intel: "https://github.com/openclaw/AXorcist/releases/download/v0.2.3/axorc-0.2.3-macos-x86_64.zip",
  )
  sha256 on_arch_conditional(
    arm:   "961312fea6a92f63979467b1b49da593537b5e9a9d44fcee298045d7ccdef276",
    intel: "70040c25fc5f3475066b8484efec82af3a3db43e87cb5b4882c6785e53ce991c",
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
