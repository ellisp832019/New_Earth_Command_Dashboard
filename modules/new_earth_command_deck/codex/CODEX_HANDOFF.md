# Codex Handoff: Build New Earth Command Deck Module

## Goal

Add a New Earth Command Deck module into the dashboard repo. This module should support Stream Deck workflows, local scripts, meeting automation, project shortcuts, and future ESP32-S3 custom hardware integration.

## Where to place it

```text
modules/new_earth_command_deck/
```

## Build tasks

1. Create a dashboard page called Command Deck.
   - Route it at `/more/command-deck`.
2. Add button cards for key actions: Start Meeting, Start Build Session, MicroGrow, BioCalm, New Earth Living, Launchpad, Knowledge Search, Finance, Assets, OBS Recording, Codex Handoff.
3. Create a local config file for paths.
4. Create a command registry JSON file.
5. Add scripts for:
   - Creating a meeting folder
   - Creating a build session log
   - Creating a Codex handoff file
   - Opening project folders
6. Add local API actions if the dashboard backend supports it.
7. Add a safety layer so destructive commands require confirmation.
8. Add logs for every command action.
9. Add documentation page inside the dashboard explaining setup and keep the module pack self-contained.
10. Add tests for command registry validation.

## Important constraints

- Local-first.
- Do not hardcode Peter's private paths directly into code. Use config files.
- Keep `.env` out of git.
- Do not make firmware upload, OTA update, delete, or archive commands one-click without confirmation.
- Keep the module generic enough to run on Windows first, then Linux later.

## First implementation target

Build the software-only version first. Stream Deck can call scripts or open URLs later.

## Acceptance criteria

- Command Deck page opens in dashboard.
- Buttons are visible and grouped by workflow.
- Meeting starter script creates the full folder structure and markdown files.
- Build session script creates a daily log.
- Codex handoff script creates a markdown handoff in the right folder.
- Config file documents all paths.
- No secrets are committed.
