# ADR - GAIA v0.9 Project Context Read-Only

## Status

Accepted

## Date

2026-08-07

## Context

GAIA v0.8 already provides a read-only embedded operations workspace in the Dashboard.
The next step is to let GAIA understand project state without granting mutation authority.

The repository also contains multiple kinds of state:

- live Git state
- recorded Project Control checkpoints
- generated scan outputs
- historical evidence

Those must not be conflated.

## Decision

Define GAIA v0.9 around a structured, allowlisted, read-only Project Context contract that:

- keeps GAIA at observe/recommend levels only
- distinguishes live observation from recorded checkpoint state
- carries provenance and freshness metadata
- allows GitHub enrichment but does not depend on it at startup
- requires evidence-backed recommendations
- excludes execution, mutation, and secret access

## Consequences

- The Dashboard can answer state and readiness questions with evidence.
- Users can see when recorded metadata diverges from live Git state.
- GAIA stays local-first and fail-closed when external data is unavailable.
- Future execution capability will require a separate architecture and separate approval path.

## Notes

- This ADR is about semantics and boundary control, not runtime execution.
- The historical controlled baseline remains immutable provenance.
- The Project Control manifest remains a checkpoint record, not an unconditional live truth source.
