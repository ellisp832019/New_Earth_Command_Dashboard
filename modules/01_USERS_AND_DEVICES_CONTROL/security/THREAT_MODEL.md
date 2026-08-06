# Threat Model

## Risks
- Unknown devices gaining access.
- Alexa/voice executing sensitive action directly.
- AI reading private folders or running commands.
- Finance data export without approval.
- Lost trusted device still having access.
- Module bypassing gatekeeper.

## Controls
- Trust levels.
- Permissions.
- Approval queue.
- Audit log.
- Request-only default for AI and voice.
- Local-first data.
