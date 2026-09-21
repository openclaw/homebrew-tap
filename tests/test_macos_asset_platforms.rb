# typed: strict
# frozen_string_literal: true

# Run with `brew ruby tests/test_macos_asset_platforms.rb`.
require "formula"
require "json"
require "open3"
require "tmpdir"

root = Pathname.new(__dir__).parent
output, error, status = Open3.capture3("python3", "-B", "-c", <<~PYTHON, root.to_s)
  import contextlib, json, pathlib, sys
  root = pathlib.Path(sys.argv[1])
  sys.path.insert(0, str(root / ".github/scripts"))
  import formula_text
  assets = {
      "darwin_arm64": ("https://github.com/openclaw/Peekaboo/releases/download/v4.4.1/peekaboo-macos-arm64.tar.gz", "a" * 64),
      "darwin_amd64": ("https://github.com/openclaw/Peekaboo/releases/download/v4.4.1/peekaboo-macos-x86_64.tar.gz", "b" * 64),
  }
  inputs = {
      "existing": (root / "Formula/peekaboo.rb").read_text(),
      "seeded": formula_text.seed_formula("peekaboo", "openclaw/Peekaboo", "4.4.1", "macOS automation CLI",
                                          "{formula}_{version}_{target}.tar.gz", macos_only=True),
  }
  with contextlib.redirect_stdout(sys.stderr):
      rendered = {name: formula_text.render_explicit_target_formula(text, "openclaw/Peekaboo", "4.4.1", assets)
                  for name, text in inputs.items()}
      for name, text in list(rendered.items()):
          universal = formula_text.update_top_level_url_and_sha(
              formula_text.update_version(text, "4.4.0"),
              "https://github.com/openclaw/Peekaboo/releases/download/v4.4.0/peekaboo-macos-universal.tar.gz",
              "c" * 64, "4.4.0",
          )
          rendered[name + "-universal"] = universal
          rendered[name + "-reconverted"] = formula_text.render_explicit_target_formula(
              universal, "openclaw/Peekaboo", "4.4.1", assets,
          )
  print(json.dumps(rendered))
PYTHON
raise error unless status.success?

platforms = [:macos, :linux].product([:arm, :intel])
targets = { arm: ["arm64", "a" * 64], intel: ["x86_64", "b" * 64] }
Dir.mktmpdir("macos-asset-platforms-") do |directory|
  paths = JSON.parse(output).map do |name, text|
    path = Pathname.new(directory)/name/"peekaboo.rb"
    path.dirname.mkpath
    path.write(text)
    platforms.each do |os, arch|
      Homebrew::SimulateSystem.with(os:, arch:) do
        klass = Formulary.load_formula("peekaboo", path, text, "MacosAssets#{name.delete("-")}#{os}#{arch}",
                                       flags: [], ignore_errors: false)
        formula = klass.new("peekaboo", path, :stable, tap: Tap.fetch("openclaw/tap"))
        target, digest = targets.fetch(arch)
        version = "4.4.1"
        if name.end_with?("-universal")
          target, digest, version = "universal", "c" * 64, "4.4.0"
        end
        expected = "https://github.com/openclaw/Peekaboo/releases/download/v#{version}/peekaboo-macos-#{target}.tar.gz"
        raise "Wrong archive for #{name}/#{os}/#{arch}" if formula.stable.url != expected
        raise "Wrong checksum for #{name}/#{os}/#{arch}" if formula.stable.checksum.hexdigest != digest
        raise "Wrong version for #{name}/#{os}/#{arch}" if formula.version.to_s != version

        requirement = formula.requirements.find { |item| item.is_a?(MacOSRequirement) }
        raise "macOS-only installation requirement missing" unless requirement&.fatal?
        if name.start_with?("existing") && requirement.version != MacOSVersion.from_symbol(:sequoia)
          raise "Maintained macOS version requirement changed"
        end

        puts "PASS #{name} formula #{os}/#{arch}: #{target}"
      end
    end
    path.to_s
  end
  system HOMEBREW_BREW_FILE, "style", "--only-cops=FormulaAudit/ComponentsOrder", *paths, exception: true
end
