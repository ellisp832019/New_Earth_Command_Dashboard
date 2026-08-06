# Voice Gateway Security

## Security posture

The Alexa Voice Gateway is deny-by-default. Alexa is treated as an external doorway, not a trusted internal system.

## Safety rules

- No direct file access.
- No direct finance access.
- No direct Obsidian vault access.
- No shell command execution.
- No AI agent execution.
- No permanent relay control.
- No dangerous hardware control.
- No raw local database access.

## First-pass allowed commands

- `dashboard.summary.today`
- `dashboard.project.status.read`
- `microgrow.status.read`
- `dashboard.note.add`
- `dashboard.focus.start`
- `dashboard.tasks.next`

## Logging

Each request should record:

- timestamp
- command name
- source
- permission result
- action taken
- blocked reason if blocked

Do not log private note contents, finance data, raw vault content, tokens, secrets, or passwords.

## Kill switch

Use:

```text
ALEXA_GATEWAY_ENABLED=false
```

This should disable all Alexa gateway requests until it is turned back on.

