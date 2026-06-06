# Dashboard Module Stub

This folder describes what Codex should build inside the New Earth Dashboard.

Suggested path:

```text
modules/new_earth_command_deck/
```

## UI sections

- Command Centre
- Meetings
- Projects
- MicroGrow
- BioCalm
- New Earth Living
- Launchpad
- AI/Codex
- Media Studio
- Omega OS
- Settings

## Components

- CommandDeckPage
- CommandButtonCard
- CommandGroup
- CommandLogPanel
- CommandSettingsPanel
- SafetyConfirmDialog

## Data files

- command_registry.json
- local_paths.json
- command_deck_settings.json

## Dashboard entry point

The first route for the module should be:

```text
/more/command-deck
```

## TODO

- TODO: load the command registry from JSON.
- TODO: persist command action logs locally.
- TODO: add safety confirmations for risky commands.
