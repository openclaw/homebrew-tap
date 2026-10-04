class Axorc < Formula
  desc "Inspect and automate macOS Accessibility from the shell"
  homepage "https://github.com/openclaw/AXorcist"
  url on_arch_conditional(
    arm:   "https://github.com/openclaw/AXorcist/releases/download/v0.2.1/axorc-0.2.1-macos-arm64.zip",
    intel: "https://github.com/openclaw/AXorcist/releases/download/v0.2.1/axorc-0.2.1-macos-x86_64.zip",
  )
  sha256 on_arch_conditional(
    arm:   "4545fa6df406414c34b2af74836976a5edbd6ae7d69ad5f4ce6d872e5ce373c9",
    intel: "5fde3ad96fdcbf203dccac494149634bfbcee6ef811df86336b33039d3efb9ab",
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
