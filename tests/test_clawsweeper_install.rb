# frozen_string_literal: true

# Run with `brew ruby tests/test_clawsweeper_install.rb [verified-envelope-directory]`.
# Exercise native installation and test in a private prefix, then remove that prefix.
# First provision Homebrew's formula_test gem group on the disposable runner.
require "formula"
require "extend/ENV"
require "formula_assertions"
require "digest"
require "fileutils"
require "json"
require "open3"
require "tmpdir"

# `brew ruby` does not activate the extensions used by native install/test bodies.
ENV.extend(Stdenv)
Pathname.activate_extensions!

root = Pathname.new(__dir__).parent
path = root/"Formula/clawsweeper.rb"
klass = Formulary.load_formula("clawsweeper", path, path.read, "ClawsweeperInstall",
                               flags: [], ignore_errors: false)
formula = klass.new("clawsweeper", path, :stable, tap: Tap.fetch("openclaw/tap"))
names = %w[clawsweeper-local.tgz manifest.json package-lock.json package.json].freeze

Dir.mktmpdir("clawsweeper-formula-install-") do |directory|
  scratch = Pathname.new(directory)
  source = scratch/"envelope"
  source.mkpath
  if ARGV.empty?
    formula.resource.stage { FileUtils.cp names, source }
  else
    provided = Pathname.new(ARGV.fetch(0)).realpath
    raise "Unexpected envelope files" if provided.children.map { |file| file.basename.to_s }.sort != names

    names.each do |name|
      input = provided/name
      raise "Non-regular envelope input" if !input.file? || input.symlink?

      FileUtils.cp input, source/name
    end
  end
  inputs = names.to_h { |name| [name, (source/name).binread] }
  manifest = JSON.parse(inputs.fetch("manifest.json"))
  manifest.fetch("files").each do |file|
    bytes = inputs.fetch(file.fetch("path"))
    raise "Envelope size mismatch" if bytes.bytesize != file.fetch("bytes")
    raise "Envelope checksum mismatch" if Digest::SHA256.hexdigest(bytes) != file.fetch("sha256")
  end
  expected = manifest.fetch("stagedFiles").to_h do |file|
    [file.fetch("path"), { "bytes" => file.fetch("bytes"), "sha256" => file.fetch("sha256") }]
  end
  lock = JSON.parse(inputs.fetch("package-lock.json"))
  registry = lock.fetch("packages").select { |_, metadata| metadata.fetch("resolved", "").start_with?("https://") }
  resource_names = registry.keys.map { |name| name.delete_prefix("node_modules/") }
  expected_resources = (resource_names + ["trufflehog"]).sort
  raise "Resource set differs from published lock" if formula.resources.map(&:name).sort != expected_resources

  registry.each do |relative, metadata|
    resource = formula.resource(relative.delete_prefix("node_modules/"))
    raise "Resource URL differs from published lock" if resource.url != metadata.fetch("resolved")

    integrity = "sha512-#{Digest::SHA512.file(resource.fetch).base64digest}"
    raise "Resource SRI differs from published lock" if integrity != metadata.fetch("integrity")
  end
  destination = scratch/"installed"
  (scratch/"home").mkpath
  install_env = {
    "HOME"         => (scratch/"home").to_s,
    "PATH"         => ENV.fetch("PATH"),
    "NODE_OPTIONS" => nil,
  }
  # Formula#run_test isolates HOME, but direct Formula#install does not.
  # Cover both npm spellings so an operator config cannot select the cache/config.
  %w[npm_config_cache NPM_CONFIG_CACHE].each { |name| install_env[name] = (scratch/"npm-cache").to_s }
  %w[userconfig globalconfig].each do |kind|
    %W[npm_config_#{kind} NPM_CONFIG_#{kind.upcase}].each do |name|
      install_env[name] = (scratch/"npm-#{kind}").to_s
    end
  end

  staging = scratch/"source"
  staging.mkpath
  names.each { |name| FileUtils.cp source/name, staging/name }
  formula.extend(Homebrew::Assertions)
  formula.define_singleton_method(:prefix) { destination }
  formula.define_singleton_method(:buildpath) { staging }
  formula.define_singleton_method(:logs) { scratch/"logs" }
  formula.define_singleton_method(:verbose?) { true }
  ENV.clear_sensitive_environment! do
    with_env(install_env) { Dir.chdir(staging) { formula.install } }
  end

  inputs.each do |name, bytes|
    raise "Installed envelope changed #{name}" if (destination/"libexec"/name).binread != bytes
    raise "Source envelope changed #{name}" if (source/name).binread != bytes
  end
  installed = destination/"libexec/node_modules/@openclaw/clawsweeper"
  package_files = installed.glob("**/*", File::FNM_DOTMATCH)
  raise "Symlink inside installed package" if package_files.any?(&:symlink?)

  actual = package_files.reject(&:directory?).to_h do |file|
    raise "Non-regular installed package file" unless file.file?

    [file.relative_path_from(installed).to_s,
     { "bytes" => file.size, "sha256" => Digest::SHA256.file(file).hexdigest }]
  end
  raise "Installed package differs from the published inventory" if actual != expected

  lock.fetch("packages").each do |relative, metadata|
    next if relative.empty?

    package = destination/"libexec"/relative
    raise "Installed dependency root is a symlink" if package.symlink?

    installed_metadata = JSON.parse((package/"package.json").read)
    if installed_metadata.fetch("version") != metadata.fetch("version")
      raise "Installed dependency version differs from lock"
    end

    has_license = package.children.any? do |file|
      file.file? && file.basename.to_s.match?(/\ALICENSE(?:\.|\z)/i)
    end
    raise "Missing installed package license" unless has_license
  end
  commands = destination.join("bin").children.map { |file| file.basename.to_s }
  raise "Unexpected installed command" if commands != ["clawsweeper"]

  # The package owns the scanner pin; a tap resource must follow that exact contract.
  probe = <<~JS
    import { reviewToolArtifact, TRUFFLEHOG_VERSION } from #{(installed/"dist/review-tool-bootstrap.js").to_s.to_json};
    console.log(JSON.stringify({ version: TRUFFLEHOG_VERSION, ...reviewToolArtifact() }));
  JS
  scanner = JSON.parse(Utils.safe_popen_read(Utils::Path.formula_opt_bin("node@24")/"node", "--input-type=module",
                                             "-e", probe))
  resource = formula.resource("trufflehog")
  raise "Scanner resource URL differs from package pin" if resource.url != scanner.fetch("url")
  raise "Scanner resource checksum differs from package pin" if resource.checksum.to_s != scanner.fetch("sha256")

  stdout, stderr, status = Open3.capture3((destination/"libexec/scanner/trufflehog").to_s, "--version")
  raise "Scanner version command failed" unless status.success?

  version = (stdout + stderr).strip
  raise "Wrong scanner version" if version != "trufflehog #{scanner.fetch("version")}"
  raise "Missing scanner license" unless (destination/"libexec/scanner/LICENSE").file?

  formula.run_test
  FileUtils.rm_rf(destination)
  raise "Private installation was not removed" if destination.exist?

  puts "PASS native install/test/private-prefix cleanup: #{actual.length} unchanged package files"
end
