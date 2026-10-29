# frozen_string_literal: true

# Install the immutable envelope without rebuilding its package or dependency lock.
class Clawsweeper < Formula
  desc "Review committed changes with a local AI command-line tool"
  homepage "https://github.com/openclaw/clawsweeper"
  url "https://github.com/openclaw/clawsweeper/releases/download/v0.3.3/clawsweeper-local-envelope.tar.gz"
  sha256 "45c1a09c666e16ef2097eb3d849a5ba9a7655b28ea5737ee3643154bca156233"
  license all_of: ["MIT", "AGPL-3.0-only", "PSF-2.0", "BSD-2-Clause", "ISC"]

  # The generic updater cannot advance the envelope's lock and scanner resources.
  livecheck do
    skip "Locked package and scanner resources require coordinated updates"
  end

  depends_on "git"
  depends_on "node@24"

  resource "argparse" do
    url "https://registry.npmjs.org/argparse/-/argparse-3.0.4.tgz"
    sha256 "564125ffdf5f0f8ef934e89d725b0cf564b45add3f310276fd35a10a996a81e2"
  end

  resource "entities" do
    url "https://registry.npmjs.org/entities/-/entities-8.1.0.tgz"
    sha256 "e9a27d66db0d0a6f2d76454219d94f5729ae2a29f08ab06c92e5f6eaa37cbe68"
  end

  resource "linkify-it" do
    url "https://registry.npmjs.org/linkify-it/-/linkify-it-6.1.0.tgz"
    sha256 "780a9e8232ea7e4c9f04348e2e2a567485c34abed805a15cfff8fff2029076b8"
  end

  resource "markdown-it" do
    url "https://registry.npmjs.org/markdown-it/-/markdown-it-15.0.3.tgz"
    sha256 "98a7453983ab0e268c17dbd5260bf7190ba46b4cca912327fc1c1a2578e4b56d"
  end

  resource "mdurl" do
    url "https://registry.npmjs.org/mdurl/-/mdurl-2.1.0.tgz"
    sha256 "23fc27c3d70e776c3aa40ec019c2be21ef43ed33b73f8476ada8715c5aabd11d"
  end

  resource "punycode.js" do
    url "https://registry.npmjs.org/punycode.js/-/punycode.js-2.3.1.tgz"
    sha256 "8768d89aa6359164220014ba575e1464e3ddff11bedff1cc268e39a21f7324a8"
  end

  resource "uc.micro" do
    url "https://registry.npmjs.org/uc.micro/-/uc.micro-3.0.0.tgz"
    sha256 "23a2704905d2f7a773f89c97be1102a4a2eb3a69b58c0e8c326a649c75552981"
  end

  resource "yaml" do
    url "https://registry.npmjs.org/yaml/-/yaml-2.9.1.tgz"
    sha256 "4ef6c54cf559b8a207b7b518378230805a1c84af239b14960e8c67c7d59de5d3"
  end

  resource "trufflehog" do
    on_macos do
      if Hardware::CPU.arm?
        url "https://github.com/trufflesecurity/trufflehog/releases/download/v3.99.4/trufflehog_3.99.4_darwin_arm64.tar.gz"
        sha256 "dc942daecb4a7795fd0a7421c66281bd4cc2ba29a265f3f6c63ecb684a6db291"
      else
        url "https://github.com/trufflesecurity/trufflehog/releases/download/v3.99.4/trufflehog_3.99.4_darwin_amd64.tar.gz"
        sha256 "c10e3ec17550e24081b9e045396cf78e494a86616736f0472024519b7416aa37"
      end
    end

    on_linux do
      if Hardware::CPU.arm?
        url "https://github.com/trufflesecurity/trufflehog/releases/download/v3.99.4/trufflehog_3.99.4_linux_arm64.tar.gz"
        sha256 "e6285aff62e692131255dca91ad300a62a479330e0b72e4eb1d60ae58908f8d5"
      else
        url "https://github.com/trufflesecurity/trufflehog/releases/download/v3.99.4/trufflehog_3.99.4_linux_amd64.tar.gz"
        sha256 "5ae9b313342d1bfa96404064c0f59e77a2cbd1824d797ca7b11e6655aa8fd9d1"
      end
    end
  end

  def install
    libexec.install "clawsweeper-local.tgz", "manifest.json", "package.json", "package-lock.json"
    ENV.prepend_path "PATH", formula_opt_bin("node@24")
    npm_args = ["--offline", "--ignore-scripts", "--cache=#{buildpath}/npm-cache",
                "--userconfig=#{buildpath}/npm-userconfig", "--globalconfig=#{buildpath}/npm-globalconfig"]

    # Homebrew verifies each resource; npm then verifies the published lock's SRI.
    # The offline install cannot resolve newer versions or run lifecycle hooks.
    resources.reject { |item| item.name == "trufflehog" }.each do |item|
      system "npm", "cache", "add", item.fetch, *npm_args
    end
    cd libexec do
      system "npm", "ci", *npm_args, "--omit=dev", "--no-audit", "--no-fund"
    end
    resource("trufflehog").stage do
      (libexec/"scanner").install "trufflehog", "LICENSE"
    end
    entrypoint = libexec/"node_modules/@openclaw/clawsweeper/dist/clawsweeper-local.js"
    (bin/"clawsweeper").write_env_script formula_opt_bin("node@24")/"node", "\"#{entrypoint}\"",
                                         PATH: "#{libexec}/scanner:#{formula_opt_bin("git")}:$PATH"
  end

  def caveats
    <<~EOS
      Reviews require a separately installed and configured Codex or OpenClaw CLI.
      This formula does not log in, register skills, or change provider credentials.
      The pinned TruffleHog scanner is private to this command.
      Release source and installed-file provenance: #{opt_libexec}/manifest.json
      Diagnostics are not implemented; --help and --version do not run a review.
    EOS
  end

  test do
    assert_equal "#{version}\n", shell_output("#{bin}/clawsweeper --version")
    assert_match "--target-dir", shell_output("#{bin}/clawsweeper --help")
    manifest = JSON.parse((libexec/"manifest.json").read)
    assert_equal "511462151487bd544a2778ef4868451b07f08683", manifest.fetch("source")
    assert_equal "44c635531274e4a0f25ee72cf911d5570bb35686", manifest.fetch("sourceTree")
    assert_equal "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                 manifest.fetch("sourceDiffSha256")
    manifest.fetch("files").each do |file|
      installed = libexec/file.fetch("path")
      assert_equal file.fetch("bytes"), installed.size
      assert_equal file.fetch("sha256"), Digest::SHA256.file(installed).hexdigest
    end
  end
end
