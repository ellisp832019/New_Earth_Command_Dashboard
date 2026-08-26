# DS05-D Governed Status Closure

Audit date: 2026-08-26
Repository: New Earth - Command Dashboard
Branch: main
HEAD: b0db0053d798ced75b114e8cdc48882245a956c0
Origin alignment: 0 ahead / 0 behind

## Status

PASS_WITH_CONTROLLED_DEFERRED_ITEMS

DS05-D is formally closed for the implemented governed-status read path. No product source files were modified during this audit.

## Production Chain

The verified production chain is:

`NEW_EARTH_PLATFORM_CORE_ROOT` -> `PlatformCoreRuntimeConfigurationResolver` -> `ConfiguredPlatformCoreDeclarationSource` -> `PlatformCoreGovernedStatusReader` -> Riverpod `platformCoreProductionCompositionProvider` and `platformCoreLiveStatusProvider` -> `PlatformCoreGovernedStatusScreen`.

The live consumer is reachable from More > Platform Core Status. Production composition creates one configured source and one reader. The consumer requests a read through the live provider and supports manual refresh. Automatic polling is not present.

## Configuration And Startup

The environment key is the single production configuration source. Windows drive-letter absolute paths, including paths with spaces, are recognized independently of the host operating system. POSIX absolute paths remain supported, and relative paths are rejected. Syntax-only validation does not require filesystem access; canonicalization and directory checks are separate runtime checks.

Missing key and null value classify as `unavailable`. Empty or whitespace values and malformed or relative supplied roots classify as `invalidRoot`. Raw environment values and operating-system exception details are not exposed.

No declaration read occurs at application startup. Unconfigured composition remains safe and unavailable. A configured consumer request performs the bounded declaration read.

## Authority And Safety

Platform Core is displayed as the declaration authority and source of truth. The screen is explicitly read-only and does not fall back to fabricated Dashboard data. There are zero declaration write methods, zero declaration write controls, and zero Platform Core file writes. No duplicate Platform Core authority was found.

The source uses bounded, allowlisted reads with path containment, UTF-8 and document validation, snapshot consistency checks, sanitized failures, and no retry after source mutation. No database, schema migration, network, process, MCP, GAIA, NEOS, or LANE behavior was added or activated by this chain. LANE-01 has no blocker in this audit.

## User States And Provenance

The consumer covers `Not configured`, `Unavailable`, `Configuration issue`, `Declaration issue`, and `Declaration available`. Error and unavailable states are not presented as a false green success state.

Available status presents Platform Core source, declaration authority, read-only status, declaration metadata, contract metadata, and the last-read timestamp. The configured canonical root remains internal to the composition and is not surfaced as a raw filesystem path.

## Validation Evidence

- Governed-status tests: PASS, 50 tests.
- Dashboard widget tests: PASS, 64 tests.
- `flutter analyze`: PASS, no issues found.
- `git diff --check`: PASS; only existing line-ending normalization warnings were reported for protected generated files.
- Protected generated files untouched by this audit: TRUE.
- Non-ignored untracked files before evidence creation: 0.
- Hard-coded development path found: FALSE.
- Live UI wiring added during this audit: FALSE.

## Controlled Deferred Items

- Source content hashing and broader provenance fingerprints remain future hardening, not DS05-D blockers.
- Broader Dashboard card presentation remains outside DS05-D.
- Future LANE-01 integration remains outside this closure.
- Combined declared-versus-observed presentation remains outside this closure.

## Closure Decision

DS05-D CLOSED: TRUE

Ready for closure commit: TRUE

This evidence document is intentionally uncommitted. No commit, push, or PR operation was performed.
