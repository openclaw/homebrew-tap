# typed: strict
# frozen_string_literal: true

# Run with `brew ruby tests/test_crabbox_install.rb`.
require "formula"
require "tmpdir"

path = Pathname.new(__dir__).parent/"Formula/crabbox.rb"
companions = %w[crabbox-jj-source crabbox-jj-source.json crabbox-jj-source.NOTICES.txt attribution.json]
runtime = %w[manifest.json linux-amd64 linux-arm64].map { |file| "crabbox-runtime/#{file}" }
# Homebrew metadata simulation does not replace native CPU predicates in install.
targets = [[OS.mac? ? :macos : :linux, Hardware::CPU.arm? ? :arm : :intel]]

targets.each do |os, arch|
  Homebrew::SimulateSystem.with(os:, arch:) do
    klass = Formulary.load_formula("crabbox", path, path.read, "CrabboxInstall#{os}#{arch}",
                                   flags: [], ignore_errors: false)
    baseline = ["crabbox"]
    baseline << "crabbox-apple-vm-helper" if os == :macos && arch == :arm
    cases = { legacy: [], complete: companions, runtime: runtime, runtime_with_jj: companions + runtime }
    companions.each_with_index { |missing, index| cases["missing-#{index}"] = companions - [missing] }
    cases.each do |name, members|
      Dir.mktmpdir("crabbox-formula-install-") do |directory|
        root = Pathname.new(directory)
        source = root/"source"
        destination = root/"installed"
        source.mkpath
        expected = (baseline + members).to_h { |file| [file, "synthetic #{file}\n"] }
        expected.each do |file, contents|
          (source/file).dirname.mkpath
          (source/file).write(contents)
        end
        formula = klass.new("crabbox", path, :stable, tap: Tap.fetch("openclaw/tap"))
        formula.define_singleton_method(:bin) { destination }
        failed = false
        begin
          Dir.chdir(source) { formula.install }
        rescue SystemExit => e
          raise if e.success?

          failed = true
        end
        native_members = members & companions
        if native_members.empty? || native_members == companions
          raise "Unexpected failure for #{os}/#{arch}/#{name}" if failed

          actual = destination.glob("**/*").select(&:file?).to_h do |file|
            [file.relative_path_from(destination).to_s, file.read]
          end
          raise "Installed contents differ for #{os}/#{arch}/#{name}" if actual != expected
        else
          raise "Partial bundle accepted for #{os}/#{arch}/#{name}" unless failed
          raise "Partial installation occurred" if destination.exist?
        end
        puts "PASS Crabbox install #{os}/#{arch}/#{name}"
      end
    end
  end
end
