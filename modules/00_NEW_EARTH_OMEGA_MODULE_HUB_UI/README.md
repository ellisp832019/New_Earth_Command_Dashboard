# New Earth Omega Module Hub UI

This pack is a complete scaffold for building the first Omega-standard **Module Hub UI** inside the New Earth Dashboard.

The goal is to create the structure and user interface first, so current and future modules can be discovered, displayed, enabled, disabled, permission-gated, docked, monitored, and later connected to real backends.

This pack is intentionally backend-light. It provides the dashboard foundation, mock module registry, manifests, UI screens, dock concepts, permission model, Omega OS records, future roadmap, and Codex prompts.

## What this creates

- A `Modules` section for the New Earth Dashboard.
- A reusable module registry model.
- Module cards for existing modules.
- Module detail pages.
- Permission and health placeholders.
- Dock layout foundation.
- Mock AI Assistant Dock panel.
- Standard `module_manifest.json` pattern for future modules.
- Omega OS record structure for governance, testing, security, change logs and decisions.

## Recommended first implementation

Build this first as a UI and state shell using mock data. Then wire real modules in one by one.

Suggested first functional modules after the shell:

1. Backup System
2. Obsidian Sync
3. Grants Tracker
4. Repo Research Engine
5. AI Assistant Dock
6. MicroGrow Control

## Dashboard design principle

Do not hard-code individual modules into the dashboard. Every module should be represented by a manifest, loaded through a registry, displayed through the Module Hub, and mounted through controlled dashboard zones.

The dashboard should act as the operating system. Modules should act as installable/enableable capabilities.

## Architecture Visual Reference

- [Omega Module Hub Architecture](./docs/architecture/module_hub/module_hub_architecture.md)
