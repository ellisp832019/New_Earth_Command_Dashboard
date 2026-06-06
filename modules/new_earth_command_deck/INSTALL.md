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

Recommended first edit:

- replace the placeholder `projects.*` paths with your actual repo folders
- confirm `meetings_path`, `obsidian_vault_path`, and `command_deck_path`
- leave `dashboard_url` on the local dashboard address unless you run it elsewhere

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

## 4a. Check the virtual deck first

Before wiring Stream Deck hardware, open the Command Deck page and confirm:

- grouped command cards render
- the setup cards point to local paths
- the OBS card shows the configured hotkeys
- recent actions appear after a command runs

## 5. Give Codex the handoff

Paste `codex/CODEX_HANDOFF.md` into Codex and ask it to implement the dashboard module.
