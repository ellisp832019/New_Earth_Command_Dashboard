# Project Context Contract V1

## Contract Shape

`ProjectContextSnapshot` is the read-only payload consumed by GAIA Project Officer.

Top-level fields:

- `contractVersion`
- `snapshotId`
- `generatedAt`
- `repository`
- `platform`
- `baseline`
- `releaseReadiness`
- `repositoryHealth`
- `risks`
- `modules`
- `dependencies`
- `verification`
- `ci`
- `releases`
- `dataQuality`
- `provenance`

## Field Semantics

- `repository` describes the live repository view.
- `platform` describes the Dashboard product and integration versioning.
- `baseline` describes recorded checkpoints and protected provenance.
- `releaseReadiness` describes the current Project Control readiness signal.
- `repositoryHealth` describes a synthesized health view.
- `risks` and `modules` are structured lists for reasoning and sorting.
- `verification`, `ci`, and `releases` are evidence-backed summaries.
- `dataQuality` explains freshness, completeness, and confidence.
- `provenance` explains where the snapshot came from and what it did not read.

## Required Behaviour

- Missing live GitHub access must not break snapshot generation.
- Missing fields should be represented as unknown or omitted, not invented.
- Recorded checkpoint values must never silently overwrite live observations.
- Historical evidence may be attached, but it must remain labeled as historical.

## Contract Boundaries

- Read only.
- Local first.
- Structured and allowlisted.
- Explicitly provenance-aware.
- No autonomous execution.

## Intended Consumers

- Dashboard UI
- local validation tools
- GAIA Project Officer reasoning
- future report generation
