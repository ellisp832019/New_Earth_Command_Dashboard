# Software Requirements

## Core software

- New Earth Dashboard
- Stream Deck software
- OBS Studio
- Google Meet / browser
- VS Code
- Git
- Python 3
- Node.js or backend runtime used by dashboard
- Obsidian
- Omega OS local folder structure

## Optional software

- Whisper transcription or local transcription tool
- ffmpeg
- PowerShell
- AutoHotkey
- OpenRGB or device LED control
- Docker for local services

## Dashboard requirements

The dashboard should expose routes/pages for:

- `/more/command-deck`
- `/meetings`
- `/projects`
- `/microgrow`
- `/biocalm`
- `/new-earth-living`
- `/launchpad`
- `/knowledge`
- `/finance`
- `/assets`
- `/settings/integrations`

## Local API requirements

The dashboard should eventually support local endpoints such as:

```text
POST /api/command-deck/actions/start-build-session
POST /api/command-deck/actions/start-meeting
POST /api/command-deck/actions/create-codex-handoff
POST /api/command-deck/actions/open-project
POST /api/command-deck/actions/log-decision
GET  /api/command-deck/status
```

## Security requirements

- Localhost only by default
- No public API exposure
- Optional local auth token
- Audit log for triggered actions
- Never store secrets in the repo
