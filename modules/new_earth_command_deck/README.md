# New Earth Command Deck

A full repo module for building a physical and software command deck for the New Earth Dashboard.

The goal is to turn a Stream Deck, keyboard shortcuts, OBS, Google Meet, Omega OS, MicroGrow, Codex, and future custom ESP32-S3 hardware into one calm, local-first mission-control system.

The first working version is the virtual Command Deck page inside the dashboard at `/more/command-deck`.

## What this repo gives you

- Full project vision and architecture
- Hardware shopping list and build phases
- Stream Deck profile design
- Dashboard integration plan
- Omega OS folder mapping
- Meeting system automation design
- OBS and recording workflow
- MicroGrow control page concept
- BioCalm and New Earth Living shortcuts
- Launchpad/crowdfunding operating page
- AI/Codex handoff templates
- Custom ESP32-S3 Command Core roadmap
- Scripts and config templates
- Codex build instructions
- A virtual command deck page that can group local routes, folders, and scripts

## Recommended repo location

Place this inside the dashboard repo as:

```text
new-earth-dashboard/modules/new_earth_command_deck/
```

Or inside Omega OS as:

```text
D:/NEW_EARTH_OMEGA_OS_PACK/23_AI_AND_AUTOMATION/COMMAND_DECK/
```

Best approach: keep the code module in the Dashboard repo and mirror docs/logs into Omega OS.

The dashboard entry point for this module is:

```text
/more/command-deck
```

## Build phases

1. Phase 0: Planning and structure
2. Phase 1: Stream Deck XL working version
3. Phase 2: Dashboard shortcut bridge
4. Phase 3: Meeting automation
5. Phase 4: MicroGrow/BioCalm/New Earth modules
6. Phase 5: Local AI and Codex workflows
7. Phase 6: Custom ESP32-S3 New Earth Command Core

## First practical milestone

Build a software-only version first:

- Dashboard buttons exist
- Keyboard shortcuts work
- Stream Deck opens pages/scripts
- Meeting folder is created automatically
- OBS recording workflow is documented
- Codex handoff files are generated

Then add physical hardware.

## Setup flow

1. Copy `config/command_deck.example.json` to `config/command_deck.json`.
2. Replace placeholder paths with your local machine paths.
3. Review `config/command_registry.example.json` to see the grouped virtual deck.
4. Open `/more/command-deck` in the dashboard and confirm the cards show up.
5. Keep private paths out of git and store only safe examples in the repo.
