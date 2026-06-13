# Security Review — Alexa Voice Gateway

## Permission posture

Default permissions should be disabled until explicitly enabled.

## Requested permissions

- voice_trigger
- local_api_access
- network_access
- audit_log

## Review notes

No backend control should be enabled during the first UI shell phase.
