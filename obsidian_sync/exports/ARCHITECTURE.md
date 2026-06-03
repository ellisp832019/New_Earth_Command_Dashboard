# Gaia Architecture

## System Overview

Gaia is a Flutter application with a feature-based structure, local persistence, and a router-driven shell.

The app centers on a dashboard-first workflow and uses local data stores and local file workflows to keep the product offline-first.

## Main Components

| Component | Purpose | Status |
|---|---|---|
| App shell and router | Material 3 shell with `go_router` branches, redirects, and nested screens | Active |
| Core database layer | Drift/SQLite database, schema migrations, seed data, and daily plan setup | Active |
| Feature modules | Dashboard, projects, tasks, planner, journal, learning, content, business, wellbeing, inbox, settings, treasury, assets, meetings, voice, and knowledge library | Active |
| Voice assistant stack | Startup gate, handsfree wake layer, shared session controller, conversation dock, and Windows speech bridge | Active |
| Supporting modules | `modules/project_repo_bridge` and `modules/NE_OBSIDIAN_SYNC_MODULE` | Supporting |

## Folder Map

```text
repo_root/
  lib/
    core/
    features/
    widgets/
  docs/
  assets/
  config/
  modules/
  tools/
  third_party/
  android/
  ios/
  linux/
  macos/
  web/
  windows/
  obsidian_sync/
```

## Data Flow

```text
User action
  -> feature screen
  -> Riverpod controller or service
  -> local repository, Drift database, or local file workflow
  -> state refresh
  -> updated UI
```

Voice flow:

```text
Wake phrase or listening input
  -> voice session controller
  -> voice assistant screen or dashboard dock
  -> local review and save
  -> refreshed local data
```

Asset and print flow:

```text
Asset or QR action
  -> feature controller
  -> local CSV/PDF/file output or printer path
  -> saved artifact or queued print job
```

## External Dependencies

- Flutter SDK and Material 3
- `flutter_riverpod`
- `go_router`
- `drift`
- `sqlite3_flutter_libs`
- `path_provider`
- `path`
- `speech_to_text`
- `third_party/speech_to_text_windows`
- `file_picker`
- `qr_flutter`
- `pdf`
- `printing`
- Local Python voice bridge in `tools/voice_bridge`

## Integration Points

- Local SQLite database for app data
- Local filesystem for exports, backups, configs, and generated artifacts
- Windows voice typing and headset gate flow
- QR label and PDF print flow
- Obsidian sync module for exported project memory notes
- `modules/project_repo_bridge` for repo scanning and project mapping work

## Architecture Risks

- The router is large and will need discipline as modules grow
- Voice behavior spans several layers, so lifecycle collisions are a real risk if session ownership is not kept strict
- Windows-only speech and headset behavior can be fragile across hardware setups
- Multiple local file workflows increase the chance of path and config mismatch
- Documentation can drift from implementation if the sync exports are not refreshed regularly
