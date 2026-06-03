# New Earth Command Dashboard Project Graph

Relationship map for the repo, notes, and vault flow.

<!-- AUTO-GENERATED:START -->
## What This Graph Shows
- The project graph is a relationship map, not another status note.
- It shows how the code folders, generated notes, and local vault all connect.

## Folder Graph
| Folder | Purpose | Relationship |
| --- | --- | --- |
| `lib/` | Flutter features, shared services, and app UI. | Primary app surface |
| `docs/` | Roadmaps, FSD docs, architecture notes, and guides. | Project memory and spec layer |
| `modules/` | Support modules like meeting system and repo tooling. | Shared operational modules |
| `assets/` | Screenshots, guides, and visual support files. | Reference material |
| `tools/` | Desktop helpers and small local scripts. | Utility layer |
| `config/` | Local configuration and path mapping. | Environment glue |
| `obsidian_sync/` | Sync scripts, exports, templates, and docs. | Obsidian integration |
| `lib/features/assets/` | 29 tracked files | Feature slice |
| `lib/features/business/` | 4 tracked files | Feature slice |
| `lib/features/content/` | 4 tracked files | Feature slice |
| `lib/features/dashboard/` | 4 tracked files | Feature slice |
| `lib/features/inbox/` | 4 tracked files | Feature slice |
| `lib/features/journal/` | 4 tracked files | Feature slice |
| `lib/features/knowledge_library/` | 2 tracked files | Feature slice |
| `lib/features/learning/` | 4 tracked files | Feature slice |
| `lib/features/meeting_system/` | 12 tracked files | Feature slice |
| `lib/features/more/` | 1 tracked files | Feature slice |
| `lib/features/planner/` | 3 tracked files | Feature slice |
| `lib/features/project_intelligence/` | 7 tracked files | Feature slice |

## Note Graph
| Note | Role | Relationship |
| --- | --- | --- |
| START_HERE.md | Human entry point | The first note to open in the vault. |
| INDEX.md | Technical hub | The menu of canonical notes and logs. |
| DOC_REGISTRY.md | Canonical map | The role map that prevents duplicate-purpose notes. |
| PROJECT_OVERVIEW.md | Project summary | What the project is and where it is heading. |
| CURRENT_STATE.md | Live state | The most detailed active status note. |
| CURRENT_PROGRESS.md | Progress signal | What works, what is incomplete, and the sync signal. |
| MILESTONE_SUMMARIES.md | Phase view | Grouped story of the project life cycle. |
| CHANGE_INTELLIGENCE.md | Churn view | What changed recently and where it happened. |
| RISK_TRACKER.md | Risk view | Current blockers and watch items. |
| BUILD_LOG.md | Snapshot log | Current build picture and latest progress. |
| FULL_BUILD_HISTORY.md | Archive | The full chronological project history. |

## Local-First Flow
- Repo source -> Code, docs, and task files in this repository.
- Sync engine -> Generates Markdown and resolves canonical note roles.
- Export folder -> Staging area under `obsidian_sync/exports`.
- Vault mirror -> Copies notes into the Omega vault project folder.
- Obsidian view -> Human reading, linking, and handwritten notes.

## Dependency Spine
- Flutter and Material 3 provide the app shell.
- `go_router` shapes the navigation graph.
- `flutter_riverpod` manages state when it is needed.
- `drift` and SQLite store local project data.
- The Obsidian sync module turns repo content into vault notes.

## Relationship Notes
- The registry defines which note owns each role.
- The start page points humans to the shortest path into the vault.
- The index keeps the canonical note set easy to scan.
- The graph note explains how the pieces connect without repeating the content of the other notes.

## Related Docs
- [[NEW_EARTH_DASHBOARD_START_HERE]]
- [[NEW_EARTH_DASHBOARD_INDEX]]
- [[NEW_EARTH_DASHBOARD_DOC_REGISTRY]]
- [[NEW_EARTH_DASHBOARD_MODULE_STATUS]]
- [[NEW_EARTH_DASHBOARD_PROJECT_MAP]]
- [[NEW_EARTH_DASHBOARD_MODULE_RELATIONS]]
- [[NEW_EARTH_DASHBOARD_PROJECT_OVERVIEW]]
- [[NEW_EARTH_DASHBOARD_CODE_MAP]]
- [[NEW_EARTH_DASHBOARD_ARCHITECTURE]]
<!-- AUTO-GENERATED:END -->
