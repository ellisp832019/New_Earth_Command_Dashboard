# Codex Import Prompt — Omega Module Hub UI

You are working inside the New Earth Dashboard Flutter/Dart project.

Import the `NEW_EARTH_OMEGA_MODULE_HUB_UI` pack as the foundation for a dashboard module/plugin system.

## Goal

Build the first version of the New Earth Dashboard Module Hub UI.

Do not implement real module backends yet. Create the Flutter structure, models, screens, mock registry, dock placeholders, permission UI, health panels, and manifest-driven module cards.

## Required behavior

Create a new dashboard section called `Modules`.

The Modules section must show existing and future modules as cards using mock/manifest data.

Each card must display:

- module name
- category
- description
- version
- status
- enabled/disabled state
- dockable state
- permission summary
- open/details button

Each module detail screen must show:

- overview
- status
- permissions
- health
- settings placeholder
- logs placeholder
- dock options
- Omega OS record link/path

Create a permission screen with approval states:

- Disabled
- Ask every time
- Allowed

Create a dock manager placeholder with zones:

- left
- right
- bottom
- fullscreen

Create a fake AI Assistant Dock placeholder panel with:

- status offline
- model not connected
- STT not connected
- TTS not connected
- permissions locked
- open settings button
- view logs button

## Architecture rules

Use clean architecture. Keep module models, module registry, dock state, and UI screens separated.

Do not couple module UI directly to Python, Ollama, Alexa, Obsidian, or MicroGrow yet.

The first pass is structure and UI only.

## Suggested Flutter file placement

Use the supplied `flutter/lib` folder as the source design. Adapt naming to match the existing app if needed.

## Acceptance criteria

- App has a visible Modules section.
- Mock modules render correctly.
- Detail screen opens for each module.
- Permission screen displays module permissions.
- Dock placeholder can show the AI Assistant Dock mock panel.
- No backend required.
- Code is clean and easy to extend.

## Architecture Visual Reference

The Module Hub architecture visual has been added at:

```text
docs/architecture/module_hub/visuals/new_earth_module_hub_architecture.png
```

Use this as the visual reference for building the Module Hub UI, module registry, dock manager, permission system, health monitor, event bus, local backend bridge, Omega OS integration, and future plugin/module shell.

Do not hard-code modules directly into the dashboard. Build the shell so future modules can be registered through manifests and mounted into the UI.
