# Security and Local-First Rules

## Principles

- Keep core workflows local
- Do not expose command APIs publicly
- Use localhost only by default
- Keep secrets out of git
- Log actions for accountability
- Confirm destructive actions

## Risk examples

| Risk | Control |
|---|---|
| Button accidentally deletes files | No destructive commands without confirmation |
| Firmware uploaded by mistake | Confirmation gate |
| OBS records private info | Clear recording status indicator |
| Secrets committed to repo | .gitignore and .env.example only |
| Dashboard API exposed | Bind to 127.0.0.1 |

## Recommended local bridge security

- Run on `127.0.0.1`
- Use a local token from `.env`
- Reject unknown actions
- Log every action to `logs/command_deck_actions.log`
