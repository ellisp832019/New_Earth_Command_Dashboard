# Implementation Plan

## Dashboard-Side Slices

1. `ProjectContextSnapshot` models and parser
2. Project Control adapter
3. local Git live-state adapter
4. provenance, freshness, and data-quality assembler
5. response composition and evidence routing
6. Dashboard Project Officer UI

## GAIA-Repo Slices

1. integration client contract extension
2. backend read-only Project Officer endpoint
3. dashboard module view and compatibility updates
4. package fixtures and regression coverage

## Dependency Order

- Dashboard snapshot assembly must exist before GAIA response expansion.
- Live Git observation should exist before live-versus-recorded comparisons.
- Provenance and freshness tagging must exist before recommendation ranking.
- GAIA backend contract changes must follow the Dashboard contract definition.

## Acceptance Gates

- contract tests pass
- parser tests pass
- snapshot validation passes
- local validation passes
- Windows release build remains green
- CI runs green on the exact PR head
