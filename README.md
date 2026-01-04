# Clawdbot's Homebrew Tap

Homebrew tap for shipping CLI tools + a few macOS apps.

## Install

```bash
brew tap clawdbot/tap
```

## Install Packages

```bash
# formula
brew install clawdbot/tap/<name>

# cask
brew install --cask clawdbot/tap/<name>
```

## Packages

### Formulae

None, yet

### Casks

None, yet

## Update / Uninstall

```bash
brew update
brew upgrade

brew uninstall <formula>
brew uninstall --cask <cask>

# casks only: remove user data
brew uninstall --cask --zap clawdbot/tap/codexbar
```

## Notes

- Run `brew info clawdbot/tap/<name>` for per-tool caveats (permissions, setup steps, etc.).
