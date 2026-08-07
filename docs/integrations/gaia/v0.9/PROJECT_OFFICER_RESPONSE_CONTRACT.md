# Project Officer Response Contract V1

## Purpose

This contract defines the shape of a read-only response from GAIA Project Officer.

## Required Fields

- `contractVersion`
- `responseId`
- `generatedAt`
- `question`
- `answer`
- `recommendation`
- `evidence`
- `provenance`
- `freshness`
- `warnings`
- `dataQuality`

## Field Guidance

- `answer` should be concise and direct.
- `recommendation` should be a next step, not a command.
- `evidence` should cite the minimum sources needed to support the answer.
- `provenance` should explain whether the answer came from live state, recorded state, derived state, or historical evidence.
- `freshness` should say whether the answer is current, checkpointed, stale, or unknown.
- `warnings` should capture uncertainty, conflicts, or missing data.

## Style Rules

- Do not overstate certainty.
- Do not hide stale data.
- Do not use external actions as part of the answer generation path.
- Keep the response deterministic where possible.

## Example Tone

`Release readiness is not green because R-002 still records version drift and the live manifest still reflects checkpoint semantics. The next step is to reconcile the semantic meaning of live versus recorded state, then refresh the evidence.` 
