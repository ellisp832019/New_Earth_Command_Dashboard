# Security Model

## Permission levels

```text
LEVEL 0 — Public
General help, system description, non-private information.

LEVEL 1 — Read-only dashboard
Today summary, project status, MicroGrow readings, gateway health.

LEVEL 2 — Low-risk write
Add note, add task, start focus mode, create build log entry.

LEVEL 3 — Protected action
Change schedule, run limited automation, temporary hardware action.

LEVEL 4 — Blocked from Alexa
Finance details, raw vault access, delete files, shell commands, AI agent execution, permanent hardware control.
```

## Default stance

Everything is denied unless explicitly allowed.

## Confirmation rules

Low-risk reads need no confirmation.
Low-risk writes may be allowed without confirmation once stable.
Protected actions must require confirmation and expiry.
Blocked actions should never be routed from Alexa.

## Kill switch

If `ALEXA_GATEWAY_ENABLED=false`, reject all Alexa requests before any command routing happens.

## Audit logging

Every voice request should create an audit record:

```json
{
  "timestamp": "2026-06-11T08:00:00Z",
  "source": "alexa",
  "intent": "GetMicroGrowStatusIntent",
  "command": "microgrow.status.read",
  "decision": "allowed",
  "permission_level": 1,
  "requires_confirmation": false
}
```

## MicroGrow rule

MicroGrow starts read-only. Do not allow relay control until:

- Physical safety rules exist
- Time-limited actions exist
- Manual override exists
- Audit log is working
- Local dashboard can revoke Alexa control instantly
