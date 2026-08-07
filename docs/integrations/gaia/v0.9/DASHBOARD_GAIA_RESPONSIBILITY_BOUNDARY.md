# Dashboard And GAIA Responsibility Boundary

## Dashboard / Project Control Owns

- observing local Git state
- optionally observing GitHub state
- assembling the structured project context
- redacting sensitive data
- tagging freshness and provenance
- publishing the read-only contract
- retaining canonical records and evidence

## GAIA Owns

- consuming the structured context
- reasoning over approved state
- explaining blockers and drift
- producing recommendations
- citing evidence in responses

## Shared Boundary Rules

- Dashboard does not delegate repository mutation to GAIA.
- GAIA does not run commands or push changes.
- Project Control remains the canonical repository-control system.
- External GitHub enrichment is helpful, but never required for startup.

## Future Boundary

Any future execute capability requires a separate architecture, separate permissions, separate audit trail, and explicit human approval.
