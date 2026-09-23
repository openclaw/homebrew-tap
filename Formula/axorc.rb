class Axorc < Formula
  desc "Inspect and automate macOS Accessibility from the shell"
  homepage "https://github.com/openclaw/AXorcist"
  url on_arch_conditional(
    arm:   "https://github.com/openclaw/AXorcist/releases/download/v0.2.0/axorc-0.2.0-macos-arm64.zip",
    intel: "https://github.com/openclaw/AXorcist/releases/download/v0.2.0/axorc-0.2.0-macos-x86_64.zip",
  )
  sha256 on_arch_conditional(
    arm:   "b98ec0fc1b29aa6a0db4b7afe6637438ba38655c985dfe0fcee2822a8d15e752",
    intel: "66640b20b3c46e324d84bce93d54513e5fa66d13ed8bdf61993968ab0e7bf453",
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
