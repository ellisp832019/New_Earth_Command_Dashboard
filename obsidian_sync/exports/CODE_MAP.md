# New Earth Command Dashboard Code Map

This note maps the important source areas and their roles.

<!-- AUTO-GENERATED:START -->
## System Overview
New Earth Command Dashboard is a local-first Flutter app with a feature-based folder structure and a router-driven shell.

## Main Components
| Component | Purpose |
| --- | --- |
| `lib/` | Flutter application source, feature modules, core services, routing, and UI widgets. |
| `docs/` | Functional specs, roadmap notes, guides, and architecture decisions. |
| `modules/` | Supporting modules such as meeting system, repo bridge, and sync tooling. |
| `assets/` | Visual assets, screenshots, guides, and brand material. |
| `config/` | Local path and asset configuration files. |
| `tools/` | Local helper scripts such as the desktop voice bridge. |
| `third_party/` | Vendored dependencies and platform-specific wrappers. |
| `obsidian_sync/` | This sync module, generated exports, templates, and scripts. |
| `lib/features/assets/` | 29 tracked files |
| `lib/features/business/` | 4 tracked files |
| `lib/features/content/` | 4 tracked files |
| `lib/features/dashboard/` | 4 tracked files |
| `lib/features/inbox/` | 4 tracked files |
| `lib/features/journal/` | 4 tracked files |
| `lib/features/knowledge_library/` | 2 tracked files |
| `lib/features/learning/` | 4 tracked files |
| `lib/features/meeting_system/` | 12 tracked files |
| `lib/features/more/` | 1 tracked files |
| `README.md` | Top-level repo guidance or configuration. |
| `TASK.md` | Top-level repo guidance or configuration. |
| `pubspec.yaml` | Top-level repo guidance or configuration. |
| `analysis_options.yaml` | Top-level repo guidance or configuration. |

## Important Folders
- `lib/` - Flutter application source, feature modules, core services, routing, and UI widgets.
- `docs/` - Functional specs, roadmap notes, guides, and architecture decisions.
- `modules/` - Supporting modules such as meeting system, repo bridge, and sync tooling.
- `assets/` - Visual assets, screenshots, guides, and brand material.
- `config/` - Local path and asset configuration files.
- `tools/` - Local helper scripts such as the desktop voice bridge.
- `third_party/` - Vendored dependencies and platform-specific wrappers.
- `obsidian_sync/` - This sync module, generated exports, templates, and scripts.
- `lib/features/assets/` - 29 tracked files
- `lib/features/business/` - 4 tracked files
- `lib/features/content/` - 4 tracked files
- `lib/features/dashboard/` - 4 tracked files
- `lib/features/inbox/` - 4 tracked files
- `lib/features/journal/` - 4 tracked files
- `lib/features/knowledge_library/` - 2 tracked files
- `lib/features/learning/` - 4 tracked files

## Data Flow
- User action in a feature screen
- Riverpod controller or local service
- Drift database, file workflow, or local helper
- State refresh and updated UI

## External Dependencies
- `Flutter and Material 3`
- `go_router`
- `flutter_riverpod`
- `drift` and SQLite
- `speech_to_text` and the Windows speech bridge
- `path_provider`, `path`, `uuid`, `file_picker`, `qr_flutter`, `pdf`, and `printing`

## Integration Points
- Local SQLite database
- Local filesystem exports and caches
- Windows voice typing and headset gate flow
- QR labels and PDF print workflows
- Obsidian sync exports for long-term project memory
- Omega OS / repo bridge supporting modules

## Known Architecture Risks
- The router and feature count are large and need discipline.
- Voice session ownership must stay singular to avoid lifecycle collisions.
- Windows speech and headset handling vary by hardware and environment.
- Local file workflows can drift if config paths are not kept consistent.
<!-- AUTO-GENERATED:END -->
