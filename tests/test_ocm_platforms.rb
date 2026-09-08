# typed: strict
# frozen_string_literal: true

# Run with `brew ruby tests/test_ocm_platforms.rb`.
require "formula"

path = Pathname.new(__dir__).parent/"Formula/ocm.rb"
targets = {
  [:macos, :arm]   => "aarch64-apple-darwin",
  [:macos, :intel] => "x86_64-apple-darwin",
  [:linux, :intel] => "x86_64-unknown-linux-gnu",
  [:linux, :arm]   => "x86_64-unknown-linux-gnu",
}

targets.each do |(os, arch), target|
  Homebrew::SimulateSystem.with(os:, arch:) do
    klass = Formulary.load_formula("ocm", path, path.read, "OcmPlatform#{os}#{arch}",
                                   flags: [], ignore_errors: false)
    formula = klass.new("ocm", path, :stable, tap: Tap.fetch("openclaw/tap"))
    url = formula.stable.url
    raise "Wrong archive for #{os}/#{arch}: #{url}" unless url.end_with?("/ocm-#{target}.tar.gz")

    requirement = formula.requirements.find { |item| item.is_a?(ArchRequirement) }
    if os == :linux
      raise "Linux must require x86_64" if requirement&.arch != :x86_64
      raise "Architecture requirement must reject unsupported installs" unless requirement.fatal?

      # Requirements inspect the real CPU, independently of metadata simulation.
      native_supported = Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      raise "Wrong native CPU acceptance" if requirement.satisfied? != native_supported
    elsif requirement
      raise "macOS must support both architectures"
    end
    puts "PASS OCM #{os}/#{arch}: #{target}"
  end
end
