# Changelog

## Unreleased

**Highlights:** Release updates fail cleanly without publishing partial or placeholder formulae, while preserving supported legacy layouts.

- Reject unrecognized release assets before partial updates while preserving smaller legacy target inventories and resources; thanks @SebTardif.
- Keep Linux source-archive URLs and checksums in sync during multi-target updates; thanks @SebTardif.
- Leave no zero-checksum formula behind when a new formula download fails; thanks @SebTardif.
- Keep reconciling later formulae when an artifact template is invalid; thanks @SebTardif.
- Fail stalled formula and cask downloads with a 30-second socket timeout; thanks @SebTardif.
- Stop stalled source-tag Git fetches and lookups after 60 seconds; thanks @SebTardif.
- Update the `slacrawl` formula to 0.8.7 with verified macOS and Linux archives for Intel and ARM.
- Update the `goplaces` cask to 0.4.9 with the `--radius` alias and signed, notarized macOS binaries.
- Automatically reconcile formulae with their latest stable source releases every three hours without downgrading or selecting drafts and prereleases.
- Preserve formula-owned install instructions and caveats while accepting exact four-platform release asset inventories and verified source-tag provenance.
- Align Crabbox tap updates with published releases and downloaded checksums, with reconciliation as a recovery path.
- Validate release-dispatch inputs and require protected-default-branch execution for formula automation.
- Correct Gitcrawl configuration paths and direct GitHub shim users to Octopool.
- Provide Homebrew formulae for axorc, clawscan, crabbox, crabfleet, crawlbar, discrawl, gitcrawl, gogcli, graincrawl, notcrawl, octopool, slacrawl, telecrawl, wacli, and wacrawl, plus the Goplaces cask.
