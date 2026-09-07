#!/usr/bin/env bash
set -euo pipefail

if [[ "${GITHUB_ACTIONS:-}" != "true" || "${RUNNER_ENVIRONMENT:-}" != "github-hosted" ]]; then
  echo "This install smoke runs only on disposable GitHub-hosted runners." >&2
  exit 1
fi

[[ "$(uname -m)" == "$EXPECTED_ARCH" ]]
export HOME="$RUNNER_TEMP/ocm-home"
export OCM_HOME="$RUNNER_TEMP/ocm-state"
export HOMEBREW_CACHE="$RUNNER_TEMP/ocm-brew-cache"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ANALYTICS=1
mkdir -p "$HOME" "$OCM_HOME"
if [[ "$RUNNER_OS" == "Linux" ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Clone the PR checkout, not the public tap's default branch.
formula="openclaw/tap/ocm"
brew tap --custom-remote openclaw/tap "$GITHUB_WORKSPACE"
tap="$(brew --repository openclaw/tap)"
[[ "$(git -C "$tap" rev-parse HEAD)" == "$(git -C "$GITHUB_WORKSPACE" rev-parse HEAD)" ]]
cmp "$GITHUB_WORKSPACE/Formula/ocm.rb" "$tap/Formula/ocm.rb"
brew install --formula "$formula"
brew test "$formula"

metadata="$RUNNER_TEMP/ocm-brew-info.json"
brew info --json=v2 "$formula" > "$metadata"
version="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["formulae"][0]["versions"]["stable"])' "$metadata")"
keg="$(brew --cellar "$formula")/$version"
binary="$keg/bin/ocm"
python3 - "$metadata" "$keg/INSTALL_RECEIPT.json" <<'PY'
import json
import sys

with open(sys.argv[1]) as handle:
    formula = json.load(handle)["formulae"][0]
with open(sys.argv[2]) as handle:
    receipt = json.load(handle)
assert any(item["version"] == formula["versions"]["stable"] for item in formula["installed"])
assert receipt["source"]["tap"] == "openclaw/tap"
PY
[[ "$("$binary" --version)" == "$version" ]]
"$binary" --help

payload="$RUNNER_TEMP/ocm-release-payload"
mkdir -p "$payload"
tar -xzf "$(brew --cache "$formula")" -C "$payload"
cmp "$payload/ocm" "$binary"
file "$binary"
if [[ "$RUNNER_OS" == "macOS" ]]; then
  [[ "$(lipo -archs "$binary")" == "$EXPECTED_ARCH" ]]
  otool -L "$binary"
  codesign --verify --strict --verbose=2 "$binary"
  codesign --verify --strict --verbose=2 --check-notarization --test-requirement '=notarized' "$binary"
else
  file "$binary" | grep -F "x86-64"
  ldd "$binary" > "$RUNNER_TEMP/ocm-linked-libraries.txt"
  cat "$RUNNER_TEMP/ocm-linked-libraries.txt"
  if grep -F "not found" "$RUNNER_TEMP/ocm-linked-libraries.txt"; then
    exit 1
  fi
fi
