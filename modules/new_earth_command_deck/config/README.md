# Command Deck Config

This folder holds the local machine settings for the New Earth Command Deck.

## Files

- `command_deck.example.json` - safe placeholder config committed to git
- `command_registry.example.json` - virtual deck layout committed to git
- `command_deck.json` - your local config file, not committed
- `command_registry.json` - optional local override, not committed

## What to fill in later

- `dashboard_url`
- `omega_os_root`
- `obsidian_vault_path`
- `meetings_path`
- `command_deck_path`
- `projects.microgrow`
- `projects.new_earth_dashboard`
- `projects.new_earth_living`
- `projects.biocalm`

## Safe defaults

The example config uses placeholder paths on purpose so the module can ship without private machine paths.

Keep the real `command_deck.json` local to your machine and update it only with paths you trust.

## Quick check

When your local file is ready, the Command Deck page should be able to:

- open dashboard routes
- open project folders
- create meeting and build session scripts
- show OBS hotkey info
- log each action locally
