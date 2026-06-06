# Install / Setup

## 1. Copy into dashboard repo

Place this repo/module at:

```text
new-earth-dashboard/modules/new_earth_command_deck/
```

## 2. Create local config

Copy:

```text
config/command_deck.example.json
```

to:

```text
config/command_deck.json
```

Edit paths for your machine.

## 3. Test scripts

```bash
python scripts/create_meeting.py --title "Test Meeting" --project "New Earth Dashboard"
python scripts/create_build_session.py --project "New Earth Dashboard"
python scripts/create_codex_handoff.py --title "Build Command Deck Module"
python scripts/validate_command_registry.py
```

## 4. Set up Stream Deck

Create buttons that:

- Open dashboard URLs
- Open folders
- Run the Python scripts
- Trigger OBS hotkeys

The dashboard page lives at:

```text
/more/command-deck
```

## 5. Give Codex the handoff

Paste `codex/CODEX_HANDOFF.md` into Codex and ask it to implement the dashboard module.
