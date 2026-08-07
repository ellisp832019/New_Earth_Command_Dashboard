# GAIA v0.9 Project Officer Architecture

## Purpose

GAIA v0.9 turns the embedded GAIA surface into an evidence-aware Project Officer.
It can read approved project state, explain it, and recommend next actions.
It cannot mutate the repository, Git history, GitHub state, or local hardware.

## Core Distinction

The architecture separates four kinds of state:

- `observed live state` from Git, GitHub, and local runtime observation
- `recorded canonical state` from Project Control YAML and evidence records
- `generated derived state` from scans and validation outputs
- `historical evidence` from prior closeouts and archived verification

No single field name is allowed to mean all four things at once.

## Current Dashboard Reality

The Dashboard already has a read-only GAIA employee surface backed by:

- `gaiaEmployeeFeatureEnabledProvider`
- `gaiaEmployeeBackendUriProvider`
- `GaiaIntegrationClient`
- `GaiaDashboardController`
- `GaiaDashboardView`

The UI explicitly states `Read-only embedded operations workspace`.
That boundary must remain intact.

## GAIA v0.9 Contract

v0.9 introduces a narrow `ProjectContextSnapshot` contract for read-only reasoning.
The contract should answer questions about:

- live Git state
- protected main state
- Project Control readiness
- risks
- module health
- verification freshness
- CI status
- release evidence
- drift between recorded and live state

## Authority Model

GAIA v0.9 stays at:

- Level 0 `Observe`
- Level 1 `Recommend`

Levels 2 and 3 are future work and are explicitly out of scope.

## Design Principles

- Prefer local-first inspection.
- Make provenance explicit.
- Treat stale data as a first-class state.
- Allow live GitHub enrichment, but never make it startup-critical.
- Preserve human review before any future execution capability.
- Keep the contract extensible without widening authority.

## Output Shape

The contract should be consumable as a JSON snapshot and as a typed reasoning response.
That lets Dashboard code and GAIA code evolve independently while staying read-only.

## Readiness Goal

GAIA v0.9 is ready when it can reliably explain:

- what changed
- what is blocking release readiness
- what is stale
- what is high priority
- which evidence supports the recommendation
