# Project Officer Threat Model

## Threats

- prompt injection from repository text
- stale checkpoint data being mistaken for live state
- untrusted generated files masquerading as canonical truth
- secret exposure through logs or evidence
- accidental authority escalation from read-only to execute
- live GitHub unavailability
- local offline drift
- path traversal or arbitrary home-directory ingestion
- cross-repository confusion between Dashboard and GAIA packages

## Mitigations

- strict source allowlist
- provenance tagging
- freshness tagging
- explicit live-versus-recorded distinction
- no secret ingestion
- no command execution
- no write capability
- no autonomous side effects
- local-first fallback behaviour

## Security Posture

GAIA Project Officer should fail closed when uncertain.
If provenance cannot be established, the response should say so.

## Prompt Injection Boundary

Repository prose is data, not instruction.
Only the architecture contract and allowlisted evidence sources define what GAIA may use.
