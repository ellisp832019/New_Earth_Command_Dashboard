# Dashboard Obsidian Alignment Report

## A. Current Structure Found

- Current Dashboard docs live in the repo documentation tree:
  - `README.md`
  - `PROJECT_INDEX.md`
  - `docs/README.md`
  - `docs/roadmap/README.md`
  - `docs/roadmap/project_now_next_later.md`
  - `docs/roadmap/release_readiness_summary.md`
  - `docs/roadmap/future_architecture_map.md`
  - `docs/architecture/module_hub/module_hub_architecture.md`
  - `docs/tasks/VOICE_BRIDGE_TASK.md`
  - `modules/NE_OBSIDIAN_SYNC_MODULE/README.md`
  - `modules/NE_OBSIDIAN_SYNC_MODULE/obsidian_sync_config.json`
  - `modules/NE_OBSIDIAN_SYNC_MODULE/exports/PROJECT_HOME.md`
  - `modules/NE_OBSIDIAN_SYNC_MODULE/exports/PROJECT_INDEX.md`
  - `modules/NE_OBSIDIAN_SYNC_MODULE/exports/MOC_HOME.md`
  - `modules/NE_REPO_INTELLIGENCE_BRIDGE/obsidian_sync_config.json`
  - `modules/NE_REPO_INTELLIGENCE_BRIDGE/profiles/new_earth_dashboard.json`
- Current Obsidian Sync Module location: `modules/NE_OBSIDIAN_SYNC_MODULE`
- Current bridge/profile location: `modules/NE_REPO_INTELLIGENCE_BRIDGE`
- Legacy alias path present: not found in this repo snapshot

## B. Target Structure

```text
01_ACTIVE_PROJECTS/
|-- 00_NEW_EARTH_DASHBOARD/
    |-- docs/
    |-- modules/
    |-- templates/
    |-- sync/
    |-- exports/
    |-- logs/
    `-- README.md
```

## C. Gap Analysis

- Dashboard target folder missing: `01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD`
- Dashboard notes were not yet separated into a dedicated active-project folder.
- Dashboard-specific migration helper was not present before this pass.
- Dashboard-specific profile exists in the bridge family, but the official active-project folder was not yet scaffolded.
- Logs, module references, templates, and exports were not yet organised under the Dashboard project folder.

## D. Required Alignment Actions

- create
- update config/profile
- add migration helper
- add compatibility alias note
- keep current docs as source material until the vault is configured

## E. Safety Notes

- The compare pass is read-only except for this report.
- Apply mode should back up differing files before overwriting anything.
- The vault root is not configured in the repo snapshot, so migration must remain reversible.

## Planned Actions

- inspect: `README.md` - current dashboard source detected
- inspect: `PROJECT_INDEX.md` - current dashboard source detected
- inspect: `docs/README.md` - current dashboard source detected
- inspect: `docs/roadmap/README.md` - current dashboard source detected
- inspect: `docs/roadmap/project_now_next_later.md` - current dashboard source detected
- inspect: `docs/roadmap/release_readiness_summary.md` - current dashboard source detected
- inspect: `docs/roadmap/future_architecture_map.md` - current dashboard source detected
- inspect: `docs/architecture/module_hub/module_hub_architecture.md` - current dashboard source detected
- inspect: `docs/tasks/VOICE_BRIDGE_TASK.md` - current dashboard source detected
- inspect: `modules/NE_OBSIDIAN_SYNC_MODULE/README.md` - current dashboard source detected
- inspect: `modules/NE_OBSIDIAN_SYNC_MODULE/obsidian_sync_config.json` - current dashboard source detected
- inspect: `modules/NE_OBSIDIAN_SYNC_MODULE/exports/PROJECT_HOME.md` - current dashboard source detected
- inspect: `modules/NE_OBSIDIAN_SYNC_MODULE/exports/PROJECT_INDEX.md` - current dashboard source detected
- inspect: `modules/NE_OBSIDIAN_SYNC_MODULE/exports/MOC_HOME.md` - current dashboard source detected
- inspect: `modules/NE_REPO_INTELLIGENCE_BRIDGE/obsidian_sync_config.json` - current dashboard source detected
- inspect: `modules/NE_REPO_INTELLIGENCE_BRIDGE/profiles/new_earth_dashboard.json` - current dashboard source detected
