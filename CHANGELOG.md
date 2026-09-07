# Changelog

## Unreleased

**Highlights:** Install OCM and Peekaboo from the tap, keep Goplaces quarantine protection, and recover release updates without publishing partial formulae.

- Add OCM v0.2.39 for macOS ARM64/Intel and Linux x86_64, preserving signed release binaries, reconciling Rust-target archives, and testing installed packages on all three platforms. Use `brew upgrade openclaw/tap/ocm`; this initial binary does not guard against self-update.
- Add the Peekaboo 4.3.1 universal macOS formula and list it in the package guide.
- Remove the deprecated Goplaces postflight hook, preserving quarantine on signed, notarized binaries and eliminating Homebrew's warning; thanks @karbo-hub.
- Validate every checksum-download redirect before following it, rejecting HTTPS downgrades, credentials, and fragments while preserving the existing host contract; thanks @SebTardif.
- Automatically reconcile formulae with their latest stable source releases every three hours without downgrading or selecting drafts and prereleases.
- Reject unrecognized release assets before partial updates while preserving smaller legacy target inventories and resources; thanks @SebTardif.
- Keep Linux source-archive URLs and checksums in sync during multi-target updates; thanks @SebTardif.
- Leave no zero-checksum formula behind when a new formula download fails; thanks @SebTardif.
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
