# Alexa Voice Gateway Integration Status

## Current State

- Dashboard integration added as a standalone route under `More`.
- Status page available at `Alexa Voice Gateway`.
- First-pass integration is read-only and low-risk.
- Gateway kill switch is supported with `ALEXA_GATEWAY_ENABLED=false`.
- Audit logging writes one JSONL event per request.

## Module Path

```text
modules/NEW_EARTH_ALEXA_VOICE_GATEWAY_MODULE/
```

## Allowed Commands

- `dashboard.summary.today`
- `dashboard.project.status.read`
- `microgrow.status.read`
- `dashboard.note.add`
- `dashboard.focus.start`
- `dashboard.tasks.next`

## Blocked Commands

- `filesystem.delete`
- `obsidian.raw_vault.read`
- `obsidian.private_notes.read`
- `finance.private.read`
- `system.shell.exec`
- `ai.agent.run`
- `microgrow.relay.permanent_control`
- `hardware.dangerous.control`
- `database.raw.read`

## TODO

- Add a real HTTPS dashboard adapter endpoint when the local API is ready.
- Keep account linking as a future-safe task only.
- Keep MicroGrow relay control blocked until the safety review is complete.
- Add real status polling for gateway health and Alexa skill config once the backend is live.

