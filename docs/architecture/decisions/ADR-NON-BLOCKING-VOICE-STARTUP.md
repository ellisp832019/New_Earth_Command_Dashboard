# ADR - Non-Blocking Voice Startup

## Status

Accepted

## Date

2026-08-06

## Context

Voice is an optional capability in the dashboard, but the startup path previously mixed voice readiness checks with shell startup and could feel like a hard dependency.

That created three problems:

- the dashboard could feel blocked by microphone, headset, or plugin setup
- failures were not always expressed through one explicit state model
- retry behavior was spread across multiple voice surfaces

## Decision

Centralize voice startup behind an explicit coordinator that:

- treats voice as optional
- starts after the dashboard shell is available
- uses a bounded timeout
- surfaces explicit startup states
- keeps retry available for recoverable failures
- never prevents the dashboard from rendering

The coordinator now exposes a visible status chip and keeps the startup flow separate from the main app shell.

## Consequences

- The dashboard opens even when voice hardware is missing or unavailable.
- Voice startup can fail without taking down the app.
- Users can retry after permission, hardware, or plugin issues.
- The test surface is clearer because startup behavior is represented as state instead of scattered conditionals.
- Voice-specific work stays optional and local-first.

## Notes

- Windows remains the primary desktop target for voice hardware probing.
- Web and unsupported platforms remain explicitly unavailable.
- Detailed state semantics live in `docs/architecture/voice/VOICE_STARTUP_CONTRACT.md`.
