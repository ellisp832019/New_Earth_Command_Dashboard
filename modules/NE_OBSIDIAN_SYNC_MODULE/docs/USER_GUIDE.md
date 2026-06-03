# NE_OBSIDIAN_SYNC_MODULE User Guide

## Purpose

This module lets you add the same Obsidian documentation workflow to any repo or project.

It is designed for the New Earth ecosystem so your projects do not become scattered across different repos, chats, notes, and folders.

The aim is simple:

```text
One project
One repeatable documentation system
One Obsidian memory layer
```

## What To Copy Into A Repo

Copy the full module folder into your repo and rename it to:

```text
obsidian_sync
```

Your repo should then look like this:

```text
your_repo/
  obsidian_sync/
    README.md
    obsidian_sync_config.json
    CODEX_OBSIDIAN_SYNC_TASK.md
    templates/
    exports/
    scripts/
    docs/
```

## Step 1 — Edit The Config

Open:

```text
obsidian_sync/obsidian_sync_config.json
```

Change these fields:

```json
{
  "project_name": "MicroGrow",
  "project_type": "firmware",
  "obsidian_vault_path": "D:/NEW_EARTH_OBSIDIAN_VAULT",
  "obsidian_project_folder": "01_ACTIVE_PROJECTS/MICROGROW"
}
```

Use the correct project name and Obsidian folder.

## Step 2 — Give Codex The Task

Open:

```text
obsidian_sync/CODEX_OBSIDIAN_SYNC_TASK.md
```

Copy the whole file into Codex and say:

```text
Use this task to scan the repo and update the files in obsidian_sync/exports. Do not modify source code.
```

Codex should then update:

```text
obsidian_sync/exports/CURRENT_STATE.md
obsidian_sync/exports/ARCHITECTURE.md
obsidian_sync/exports/ROADMAP.md
obsidian_sync/exports/DECISIONS.md
obsidian_sync/exports/BUILD_LOG.md
obsidian_sync/exports/WEEKLY_REPORT.md
```

## Step 3 — Sync To Obsidian On Windows

From PowerShell:

```powershell
cd path/to/your_repo/obsidian_sync/scripts
./sync_to_obsidian.ps1
```

The files will be copied into the Obsidian folder defined in your config.

## Step 4 — Sync To Obsidian On Linux Or Mac

From terminal:

```bash
cd path/to/your_repo/obsidian_sync/scripts
./sync_to_obsidian.sh
```

## Recommended Folder Mapping

```text
MicroGrow              → 01_ACTIVE_PROJECTS/MICROGROW
BioCalm                → 01_ACTIVE_PROJECTS/BIOCALM
New Earth Living       → 01_ACTIVE_PROJECTS/NEW_EARTH_LIVING
New Earth Dashboard    → 01_ACTIVE_PROJECTS/NEW_EARTH_DASHBOARD
New Earth Website      → 01_ACTIVE_PROJECTS/NEW_EARTH_WEBSITE
Omega OS               → 02_OPERATING_SYSTEM/OMEGA_OS
Finance & Treasury     → 17_FINANCE_AND_TREASURY
Assets & Equipment     → 18_ASSETS_EQUIPMENT_AND_PARTS
```

## Weekly Workflow

Use this once per week per active repo:

1. Open repo in VS Code.
2. Pull latest changes.
3. Ask Codex to run the Obsidian sync task.
4. Review the exported markdown files.
5. Run the sync script.
6. Open Obsidian and review the project page.

## Daily Lightweight Workflow

At the end of a build session, update only:

```text
BUILD_LOG.md
DECISIONS.md
```

This keeps your vault alive without turning documentation into a massive job.

## Best Practice

Do not use Obsidian as another messy storage folder.

Use it as:

```text
Long-term project memory
Decision record
Architecture map
Roadmap tracker
Weekly reporting layer
```

Use GitHub/repos as the source of truth for code.
Use Obsidian as the source of truth for understanding.
Use the Dashboard as the source of truth for daily action.

## Important Rule

Do not let Codex endlessly redesign the vault.

Codex should update the content, not constantly change the structure.

## Good Codex Prompt

```text
Run the Obsidian sync task.
Scan the repo.
Update only obsidian_sync/exports.
Do not change source code.
Keep it practical and accurate.
Highlight risks and next actions clearly.
```

## Bad Codex Prompt

```text
Improve everything and reorganise the project.
```

That creates fragmentation.

## The Goal

This module should make every New Earth project self-documenting.

```text
Repo = source code truth
Obsidian = memory truth
Dashboard = action truth
Codex = documentation engineer
```
