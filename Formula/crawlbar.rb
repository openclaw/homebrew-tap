class Crawlbar < Formula
  desc "macOS menu bar control plane for local-first crawler CLIs"
  homepage "https://github.com/openclaw/crawlbar"
  url "https://github.com/openclaw/crawlbar/releases/download/v0.4.2/CrawlBar-v0.4.2-macos.zip"
  sha256 "e9f12f8356d576baea0e2b8fb755443aac4f54b8511b311129cab0a25d016f2c"
  license "MIT"

  depends_on macos: :sonoma

  def install
    if (buildpath/"CrawlBar.app").directory?
      prefix.install "CrawlBar.app"
    else
      odie "release archive does not contain CrawlBar.app/Contents" unless (buildpath/"Contents/Info.plist").exist?

      (prefix/"CrawlBar.app").install "Contents"
    end
    bin.write_exec_script prefix/"CrawlBar.app/Contents/Helpers/crawlbar"
  end

  def caveats
    <<~EOS
      Launch the menu bar app with:
        open #{opt_prefix}/CrawlBar.app

      The CLI is installed as:
        crawlbar
    EOS
  end

  test do
    app = prefix/"CrawlBar.app"
    signature = shell_output("codesign -d --verbose=4 #{app} 2>&1")
    architectures = shell_output("lipo -archs #{app}/Contents/MacOS/CrawlBar")
    bundle_id = shell_output("/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' #{app}/Contents/Info.plist")
    bundle_version = shell_output(
      "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' #{app}/Contents/Info.plist",
    )

    assert_match "crawlbar commands:", shell_output("#{bin}/crawlbar --help")
    assert_path_exists app/"Contents/Resources/CrawlBar_CrawlBar.bundle/google.png"
    assert_equal "com.vincentkoc.CrawlBar", bundle_id.strip
    assert_equal version.to_s, bundle_version.strip
    assert_match "Authority=Developer ID Application: OpenClaw Foundation (FWJYW4S8P8)", signature
    assert_match "TeamIdentifier=FWJYW4S8P8", signature
    assert_match "flags=0x10000(runtime)", signature
    assert_match "arm64", architectures
    assert_match "x86_64", architectures
    system "codesign", "--verify", "--deep", "--strict", app
    system "spctl", "--assess", "--type", "execute", app
    system "xcrun", "stapler", "validate", app
  end
end
