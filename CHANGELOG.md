# Changelog

## Unreleased

**Highlights:** Restore normal tap installation for every package, install OCM and Peekaboo, and recover release updates without publishing partial formulae.

- Preserve both files when a combined formula/cask update fails during input validation, download, or rendering.
- Fix `brew tap openclaw/tap` rejecting the entire tap when validating OCM on Linux ARM64; retain the Linux x86_64 installation requirement and validate all Homebrew platforms in CI; thanks @jandubois.
- Update OCM to v0.2.45 for macOS ARM64/Intel and Linux x86_64, including environment artifact exports, stopped-session recovery, environment-variable UI paths, and safer environment roots. Preserve signed release binaries; use `brew upgrade openclaw/tap/ocm`.
- Add the Peekaboo universal macOS formula, update it to 4.3.2, and match its v4 help header in the installed smoke test.
- Remove the deprecated Goplaces postflight hook, preserving quarantine on signed, notarized binaries and eliminating Homebrew's warning; thanks @karbo-hub.
- Validate every checksum-download redirect before following it, rejecting HTTPS downgrades, credentials, and fragments while preserving the existing host contract; thanks @SebTardif.
- Automatically reconcile formulae with their latest stable source releases every three hours without downgrading or selecting drafts and prereleases.
- Reject unrecognized release assets before partial updates while preserving smaller legacy target inventories and resources; thanks @SebTardif.
- Keep Linux source-archive URLs and checksums in sync during multi-target updates; thanks @SebTardif.
- Leave no zero-checksum formula behind when a new formula download fails; thanks @SebTardif.
- Keep release URLs and checksums synchronized when a formula places its explicit version between them, and preserve the formula if any OCM archive download fails.
- Keep reconciling later formulae when an artifact template is invalid; thanks @SebTardif.
- Fail stalled formula and cask downloads with a 30-second socket timeout; thanks @SebTardif.
- Stop stalled source-tag Git fetches and lookups after 60 seconds; thanks @SebTardif.
- Update the `slacrawl` formula to 0.8.7 with verified macOS and Linux archives for Intel and ARM.
- Update the `goplaces` cask to 0.4.9 with the `--radius` alias and signed, notarized macOS binaries.
- Preserve formula-owned install instructions and caveats while accepting exact four-platform release asset inventories and verified source-tag provenance.
- Align Crabbox tap updates with published releases and downloaded checksums, with reconciliation as a recovery path.
- Validate release-dispatch inputs and require protected-default-branch execution for formula automation.
- Correct Gitcrawl configuration paths and direct GitHub shim users to Octopool.
- Provide Homebrew formulae for axorc, clawscan, clawdex, crabbox, crabfleet, crawlbar, discrawl, gitcrawl, gogcli, graincrawl, notcrawl, octopool, slacrawl, telecrawl, wacli, and wacrawl, plus the Goplaces cask.
