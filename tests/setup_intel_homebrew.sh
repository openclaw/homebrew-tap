#!/usr/bin/env bash
set -euo pipefail

if [[ "${GITHUB_ACTIONS:-}" != true || "${RUNNER_ENVIRONMENT:-}" != github-hosted || "${RUNNER_OS:-}" != macOS ]]; then
  echo "Intel Homebrew setup is restricted to disposable GitHub-hosted macOS runners." >&2
  exit 1
fi

if ! /usr/bin/arch -x86_64 /usr/bin/true; then
  sudo /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi
/usr/bin/arch -x86_64 /usr/bin/true

# Homebrew 7 removed Intel macOS Ruby; 6.0.22 supports both Intel and macOS 27.
prefix="$RUNNER_TEMP/intel-homebrew"
revision=08e85c4e42f5d8f1ea17c36cb59cf61c2ccb26c3
git init --quiet "$prefix"
git -C "$prefix" remote add origin https://github.com/Homebrew/brew
git -C "$prefix" fetch --depth 1 origin "$revision"
git -C "$prefix" checkout --quiet --detach FETCH_HEAD
test "$(git -C "$prefix" rev-parse HEAD)" = "$revision"
test "$(/usr/bin/arch -x86_64 "$prefix/bin/brew" --prefix)" = "$prefix"
/usr/bin/arch -x86_64 "$prefix/bin/brew" --version
printf '%s\n' "$prefix/bin" "$prefix/sbin" >> "$GITHUB_PATH"
printf 'HOMEBREW_INTEL_PREFIX=%s\n' "$prefix" >> "$GITHUB_ENV"
