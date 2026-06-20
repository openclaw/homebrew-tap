class Crawlbar < Formula
  desc "macOS menu bar control plane for local-first crawler CLIs"
  homepage "https://github.com/openclaw/crawlbar"
  url "https://github.com/openclaw/crawlbar/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "f4ba18c1f1d10f6ee64a06167fc9cd7400b9b1fd5e0e7ea10d6cf87635dedc88"
  license "MIT"
  head "https://github.com/openclaw/crawlbar.git", branch: "main"

  depends_on macos: :sonoma
  uses_from_macos "swift" => :build

  def install
    system "swift", "build", "-c", "release", "--disable-sandbox", "--product", "CrawlBar"
    system "swift", "build", "-c", "release", "--disable-sandbox", "--product", "crawlbarctl"

    app_binary = Pathname(Dir[".build/**/release/CrawlBar"].first)
    cli_binary = Pathname(Dir[".build/**/release/crawlbarctl"].first)
    resource_bundle = Pathname(Dir[".build/**/release/CrawlBar_CrawlBar.bundle"].first)

    app = prefix/"CrawlBar.app"
    contents = app/"Contents"
    macos = contents/"MacOS"
    helpers = contents/"Helpers"
    resources = contents/"Resources"
    macos.install app_binary
    helpers.install cli_binary => "crawlbar"
    app.install resource_bundle
    bin.write_exec_script helpers/"crawlbar"
    system "Scripts/generate_app_icon.swift", resources/"CrawlBar.icns"
    (contents/"Info.plist").write <<~PLIST
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleExecutable</key>
        <string>CrawlBar</string>
        <key>CFBundleIdentifier</key>
        <string>com.vincentkoc.CrawlBar</string>
        <key>CFBundleName</key>
        <string>CrawlBar</string>
        <key>CFBundleIconFile</key>
        <string>CrawlBar</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>0.4.0</string>
        <key>CFBundleVersion</key>
        <string>1</string>
        <key>LSUIElement</key>
        <true/>
      </dict>
      </plist>
    PLIST

    doc.install "README.md", "LICENSE", "CONTRIBUTING.md"
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
    assert_match "crawlbar commands:", shell_output("#{bin}/crawlbar --help")
    assert_path_exists prefix/"CrawlBar.app/CrawlBar_CrawlBar.bundle/google.png"
  end
end
