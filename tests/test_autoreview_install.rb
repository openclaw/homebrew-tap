# typed: strict
# frozen_string_literal: true

# Run with `brew ruby tests/test_autoreview_install.rb <extracted-release-source>`.
# Exercise native Formula installation in a private prefix, not the global Cellar.
require "formula"
require "formula_assertions"
require "fileutils"
require "tmpdir"

root = Pathname.new(__dir__).parent
source = Pathname.new(ARGV.fetch(0)).realpath
path = root/"Formula/autoreview.rb"
klass = Formulary.load_formula("autoreview", path, path.read, "AutoreviewInstall",
                               flags: [], ignore_errors: false)
Dir.mktmpdir("autoreview-formula-install-") do |directory|
  scratch = Pathname.new(directory)
  destination = scratch/"installed"
  staging = scratch/"source"
  staging.mkpath
  FileUtils.cp_r [source/"skills", source/".release-version", source/"LICENSE"], staging
  expected = (source/"skills/autoreview").glob("**/*").select(&:file?).to_h do |file|
    [file.relative_path_from(source/"skills/autoreview").to_s, file.binread]
  end
  formula = klass.new("autoreview", path, :stable, tap: Tap.fetch("openclaw/tap"))
  formula.extend(Homebrew::Assertions)
  formula.define_singleton_method(:prefix) { destination }
  formula.define_singleton_method(:logs) { scratch/"logs" }
  formula.define_singleton_method(:verbose?) { true }
  Dir.chdir(staging) { formula.install }
  actual = (destination/"libexec/skills/autoreview").glob("**/*").select(&:file?).to_h do |file|
    [file.relative_path_from(destination/"libexec/skills/autoreview").to_s, file.binread]
  end
  raise "Installed skill differs from release source" if actual != expected

  commands = destination.join("bin").children.map { |file| file.basename.to_s }
  raise "Unexpected installed command" if commands != ["autoreview"]

  formula.run_test
  puts "PASS native Autoreview Formula install/test: #{actual.length} unchanged skill files"
end
