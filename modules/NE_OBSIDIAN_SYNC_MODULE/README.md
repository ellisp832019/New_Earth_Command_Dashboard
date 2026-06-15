# New Earth Knowledge Fabric Sync

Local-first Obsidian and Omega OS documentation sync for New Earth repos.

This module scans a repo, generates stable project-memory notes, mirrors the repo's Markdown docs into an Obsidian vault project folder, and writes a dashboard-friendly status export.

## Purpose

Use this module when you want a reusable documentation automation layer for:

- New Earth Dashboard
- MicroGrow
- Omega OS
- XR OS
- Grants
- AI Security Layer
- any future New Earth repo that needs local-first project memory

It is designed to stay:

- local-first
- Windows-friendly
- Obsidian-plugin-free
- the canonical home for the Obsidian sync module

For the Dashboard active-project folder, use the dedicated profile:

- `modules/NE_OBSIDIAN_SYNC_MODULE/profiles/new_earth_dashboard.json`

## What It Produces

Core generated notes:

- `PROJECT_HOME.md`
- `PROJECT_INDEX.md`
- `MOC_HOME.md`
- `START_HERE.md`
- `INDEX.md`
- `DOC_REGISTRY.md`
- `PROJECT_GRAPH.md`
- `PROJECT_MAP.md`
- `MODULE_STATUS.md`
- `MODULE_RELATIONS.md`
- `PROJECT_OVERVIEW.md`
- `CURRENT_STATE.md`
- `CURRENT_PROGRESS.md`
- `ARCHITECTURE.md`
- `CODE_MAP.md`
- `ROADMAP.md`
- `MILESTONE_SUMMARIES.md`
- `CHANGE_INTELLIGENCE.md`
- `RISK_TRACKER.md`
- `TASKS.md`
- `DECISIONS.md`
- `DECISIONS_LOG.md`
- `BUILD_LOG.md`
- `BUILD_LOG_SUMMARY.md`
- `FULL_BUILD_HISTORY.md`
- `WEEKLY_REPORT.md`
- `OPEN_QUESTIONS.md`
- `DAILY_SYNC_LOG.md`
- `SESSION_NOTE.md`
- `sync_report.md`
- `dashboard_status.json`

Repo docs are also mirrored into the vault project folder under a `docs/` subfolder.

The generated hub notes are intentionally cross-linked so the vault graph has a strong center:

- `PROJECT_HOME.md`
- `PROJECT_INDEX.md`
- `MOC_HOME.md`
- `START_HERE.md`
- `INDEX.md`
- `DOC_REGISTRY.md`
- `PROJECT_GRAPH.md`
- `PROJECT_MAP.md`
- `sync_report.md`

## Setup

1. Keep this module under `modules/NE_OBSIDIAN_SYNC_MODULE`.
2. Edit `obsidian_sync_config.json` in this folder.
3. Set your repo root path, docs source path, vault path, project folder, related projects, tags, dashboard export path, and sync mode.
4. Make sure Python is installed.

### Config Example

```json
{
  "project_name": "PROJECT_NAME_HERE",
  "project_type": "research",
  "repo_path": "../..",
  "docs_source_path": "docs",
  "obsidian_vault_path": "",
  "obsidian_project_folder": "",
  "dashboard_export_path": "",
  "vault_note_prefix": "PROJECT_NAME_",
  "sync_mode": "manual",
  "tags": ["knowledge-fabric", "local-first", "obsidian"],
  "related_projects": ["New Earth Dashboard", "Omega OS"],
  "export_docs": ["PROJECT_HOME.md", "PROJECT_INDEX.md", "MOC_HOME.md", "START_HERE.md"]
}
```

### Dashboard Profile

Use these Dashboard-specific values:

- project folder: `01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD`
- docs folder: `01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD/docs`
- project type: `command-centre / dashboard / operating system hub`
- dashboard export path: `01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD/exports`
- compatibility alias: `01_ACTIVE_PROJECTS/docs`

### Sync Modes

- `manual` - run on demand
- `commit` - use when you want a commit-focused sync cadence
- `daily` - use when you want a daily session-note rhythm

The mode is recorded in the generated reports and dashboard export.

## Manual Sync

Run from this module root:

```powershell
python .\scripts\sync_obsidian.py sync
```

Or use the PowerShell wrapper:

```powershell
.\scripts\sync_to_obsidian.ps1
```

To open a visible PowerShell window that stays open after the sync finishes:

```powershell
.\scripts\sync_to_obsidian_terminal.ps1
```

## Dashboard Migration

Compare only:

```powershell
python .\scripts\obsidian_sync\migrate_dashboard_docs.py --compare
```

Dry run:

```powershell
python .\scripts\obsidian_sync\migrate_dashboard_docs.py --dry-run
```

Apply:

```powershell
python .\scripts\obsidian_sync\migrate_dashboard_docs.py --apply
```

## Watch Mode

```powershell
.\scripts\sync_to_obsidian.ps1 -Watch
```

Or:

```powershell
python .\scripts\sync_obsidian.py watch
```

Visible terminal window:

```powershell
.\scripts\sync_to_obsidian_terminal.ps1 -Watch
```

## Optional Git Hook Usage

If you want the sync to run after local commits, call the PowerShell wrapper from a Git hook script and keep it local-only.

Example approach:

- run `sync_to_obsidian.ps1` after commit steps
- keep the hook disabled on machines that do not have the vault path configured
- do not make the hook block the commit unless that is the behaviour you want

## Dashboard Integration

The sync writes `modules/NE_OBSIDIAN_SYNC_MODULE/exports/dashboard_status.json` with:

- module name
- project name
- status
- last sync time
- docs synced count
- broken link count
- current branch
- latest commit
- dirty working tree state
- warnings and errors

If `dashboard_export_path` is set, the same JSON is mirrored there too.

That means the sync bundle is not just copying notes. It is also rebuilding the project index and backlinks that make Obsidian easier to navigate.

## Troubleshooting

- If nothing syncs, check `obsidian_vault_path` and `obsidian_project_folder`.
- If repo docs are missing in Obsidian, confirm `docs_source_path` points at the right folder.
- If wiki links are flagged as broken, either add the target note, update the link, or add the related project to the config.
- If PowerShell says Python is missing, install Python or point the wrapper at the correct interpreter.
- If dashboard export is empty, confirm the export path exists and is writable.
- If Dashboard notes still sit under the legacy `01_ACTIVE_PROJECTS/docs` alias, compare first, then dry-run, then apply.

## Backward Compatibility

The legacy shim is removed now, so use this bundle directly.

Existing notes stay in place, and this bundle is now the source of truth for the Knowledge Fabric layer.
