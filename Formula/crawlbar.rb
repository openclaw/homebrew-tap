class Crawlbar < Formula
  desc "macOS menu bar control plane for local-first crawler CLIs"
  homepage "https://github.com/openclaw/crawlbar"
  url on_arch_conditional(
    arm:   "https://github.com/openclaw/crawlbar/releases/download/v0.6.0/CrawlBar-v0.6.0-macos-arm64.zip",
    intel: "https://github.com/openclaw/crawlbar/releases/download/v0.6.0/CrawlBar-v0.6.0-macos-x86_64.zip",
  )
  sha256 on_arch_conditional(
    arm:   "70d0be07dbbd990b6820093f3038bd9031c9cd582b8d47f5332f0f425c1c25a9",
    intel: "bf8542c2cf12ddbd6b88f4af676f101c8455af72d3d4da6500a7cde6ad34cf79",
  )
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
    expected_architectures = [Hardware::CPU.arm? ? "arm64" : "x86_64"]
    %w[MacOS/CrawlBar Helpers/crawlbar].each do |binary|
      assert_equal expected_architectures, shell_output("lipo -archs #{app}/Contents/#{binary}").split.sort
    end
    bundle_id = shell_output("/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' #{app}/Contents/Info.plist")
    bundle_version = shell_output(
      "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' #{app}/Contents/Info.plist",
    )

    assert_match "crawlbar commands:", shell_output("#{bin}/crawlbar --help")
    resources = app/"Contents/Resources/CrawlBar_CrawlBar.bundle"
    resources /= "Contents/Resources" if (resources/"Contents/Resources").directory?
    assert_path_exists resources/"google.png"
    assert_equal "com.vincentkoc.CrawlBar", bundle_id.strip
    assert_equal version.to_s, bundle_version.strip
    assert_match "Authority=Developer ID Application: OpenClaw Foundation (FWJYW4S8P8)", signature
    assert_match "TeamIdentifier=FWJYW4S8P8", signature
    assert_match "flags=0x10000(runtime)", signature
    system "codesign", "--verify", "--deep", "--strict", app
    system "spctl", "--assess", "--type", "execute", app
    system "xcrun", "stapler", "validate", app
  end
end
