# Obsidian Sync Module User Guide

## Purpose

This module keeps a local-first Markdown project memory layer up to date.

It scans a repo, generates reusable project notes, mirrors repo docs into an Obsidian vault, and can publish a dashboard status export.

## Setup

1. Keep the module under `modules/NE_OBSIDIAN_SYNC_MODULE`.
2. Edit `obsidian_sync_config.json` in this folder.
3. Set your repo root path, docs source path, vault path, and project folder.
4. Set the optional dashboard export path if you want the JSON status file mirrored.
5. Add tags, related projects, and a sync mode if you want the generated notes to carry more context.
6. For Dashboard, use `profiles/new_earth_dashboard.json` or set `obsidian_project_folder` to `01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD`.
7. Run the manual sync command.
8. The sync will also rebuild the project hub notes and backlinks automatically.

## Manual Sync

```powershell
.\scripts\sync_to_obsidian.ps1
```

If you want a dedicated visible PowerShell window that stays open when the run finishes:

```powershell
.\scripts\sync_to_obsidian_terminal.ps1
```

## Watch Mode

```powershell
.\scripts\sync_to_obsidian.ps1 -Watch
```

Or launch the visible terminal wrapper:

```powershell
.\scripts\sync_to_obsidian_terminal.ps1 -Watch
```

## Dashboard Migration

Compare the current tree and write the alignment report:

```powershell
python .\scripts\obsidian_sync\migrate_dashboard_docs.py --compare
```

Preview exact file operations:

```powershell
python .\scripts\obsidian_sync\migrate_dashboard_docs.py --dry-run
```

Apply the scaffold and mapping notes:

```powershell
python .\scripts\obsidian_sync\migrate_dashboard_docs.py --apply
```

## Safety

- The module is local-first and does not require cloud sync.
- The vault path should be configured before mirror mode is used.
- If dashboard mirroring is disabled, leave `dashboard_export_path` blank.
- The shipped config uses placeholder vault values so nothing is copied until you wire in your own paths.

## Notes

The generated files are intended to land in the configured project folder inside your vault, with a project-specific prefix if desired.

If the module sits under `modules/NE_OBSIDIAN_SYNC_MODULE`, the repo root path usually points two levels up from the module folder.

Open `PROJECT_HOME.md` first, then use `PROJECT_INDEX.md` or `MOC_HOME.md` for deeper navigation.

If you want the graph to feel denser, also open `DOC_REGISTRY.md`, `PROJECT_GRAPH.md`, and `PROJECT_MAP.md`. Those are the main structural hubs.

For Dashboard, the active-project folder should be `01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD`.
