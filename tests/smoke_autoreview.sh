#!/bin/bash
set -euo pipefail

# This lifecycle test owns only a disposable hosted runner's installation.
test "${GITHUB_ACTIONS:-}" = true
test -n "${RUNNER_TEMP:-}"
if [[ "$(uname -s)" == Linux ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

formula=openclaw/tap/autoreview
brew tap --custom-remote openclaw/tap "$GITHUB_WORKSPACE"
tap="$(brew --repository openclaw/tap)"
test "$(git -C "$tap" rev-parse HEAD)" = "$(git rev-parse HEAD)"
cmp Formula/autoreview.rb "$tap/Formula/autoreview.rb"
brew audit --strict "$formula"

preserved="$RUNNER_TEMP/autoreview-user-data"
mkdir -p "$preserved/codex" "$preserved/reports"
printf '%s\n' '{"synthetic":true}' > "$preserved/codex/auth.json"
printf '%s\n' 'synthetic report to preserve' > "$preserved/reports/review.md"
export CODEX_HOME="$preserved/codex"

brew install --build-from-source "$formula"
brew test "$formula"
installed="$(brew --prefix "$formula")"
archive="$(brew --cache "$formula")"
# Homebrew verifies the pinned archive checksum; compare every installed skill byte.
python3 - "$archive" "$installed" <<'PYTHON'
import hashlib
import pathlib
import sys
import tarfile

archive, installed = map(pathlib.Path, sys.argv[1:])
expected = {}
with tarfile.open(archive, "r:gz") as source:
    for entry in source:
        parts = pathlib.PurePosixPath(entry.name).parts
        if len(parts) > 3 and parts[1:3] == ("skills", "autoreview") and entry.isfile():
            expected["/".join(parts[3:])] = source.extractfile(entry).read()
skill = installed / "libexec/skills/autoreview"
actual = {str(p.relative_to(skill)): p.read_bytes() for p in skill.rglob("*") if p.is_file()}
assert expected and actual == expected, "installed skill differs from published archive"
print(f"PASS installed source provenance: {len(actual)} files, archive SHA256 {hashlib.sha256(archive.read_bytes()).hexdigest()}")
PYTHON

before="$("$installed/bin/autoreview" --version)"
brew reinstall --build-from-source "$formula"
test "$("$(brew --prefix "$formula")/bin/autoreview" --version)" = "$before"
brew test "$formula"
brew uninstall "$formula"
test ! -e "$installed"
test "$(cat "$preserved/codex/auth.json")" = '{"synthetic":true}'
test "$(cat "$preserved/reports/review.md")" = 'synthetic report to preserve'
printf '%s\n' 'PASS clean install/reinstall/uninstall; external auth/report fixtures preserved'
