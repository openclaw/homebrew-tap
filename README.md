# OpenClaw Homebrew Tap

![Homebrew Tap banner](docs/assets/readme-banner.jpg)

Homebrew tap for shipping OpenClaw CLI tools.

## Install

```bash
brew tap openclaw/tap
```

## Install Packages

```bash
# formula
brew install openclaw/tap/<name>

# cask
brew install --cask openclaw/tap/<name>
```

## Packages

### Formulae

- `crabbox` — Remote Linux test boxes for dirty worktrees and CI hydration
- `crabfleet` — Fleet management CLI for Crabbox workers
- `crawlbar` — macOS menu bar control plane for local-first crawler CLIs
- `discrawl` — Mirror Discord into SQLite and search server history locally
- `gitcrawl` — Local GitHub issue and PR archive with gh-compatible caching
- `gogcli` — Google CLI for Gmail, Calendar, Drive, Docs, Sheets, and more
- `goplaces` — Modern Go client + CLI for the Google Places API (New)
- `graincrawl` — Local-first Granola crawler into SQLite and Markdown
- `notcrawl` — Local-first Notion crawler into SQLite and normalized Markdown
- `octopool` — Org-authenticated GitHub read relay and gh-compatible cache shim
- `slacrawl` — Go-based CLI for mirroring Slack workspace data into local SQLite
- `telecrawl` — Telegram Desktop archive CLI with encrypted Git backups
- `wacli` — WhatsApp CLI built on whatsmeow
- `wacrawl` — Read-only WhatsApp Desktop archive CLI

### Casks

None, yet

## Update / Uninstall

```bash
brew update
brew upgrade

brew uninstall <formula>
brew uninstall --cask <cask>

# casks only: remove user data
brew uninstall --cask --zap openclaw/tap/<name>
```

## Notes

- Run `brew info openclaw/tap/<name>` for per-tool caveats (permissions, setup steps, etc.).

## Maintainers

The `Update Formula` workflow accepts a Homebrew formula token, a semantic release tag, and a
GitHub repository in `owner/repo` form. Optional artifact inputs must resolve to HTTPS release
assets and may use only the placeholders documented by the workflow. Pull requests and updates
to `main` run the updater tests and validate every formula's Ruby syntax.
