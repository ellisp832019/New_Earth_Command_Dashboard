# NE_OBSIDIAN_SYNC_MODULE

Universal New Earth Obsidian Sync Module.

Drop this folder into any repo or project to help Codex scan the project, generate structured Obsidian-ready documentation, and sync the output into your New Earth Obsidian Vault.

## What It Does

```text
Any Repo / Project
    ↓
Codex scans source, docs, README and configs
    ↓
Codex updates /obsidian_sync/exports
    ↓
Sync script copies exports into Obsidian
    ↓
Your vault becomes the long-term memory of the project
```

## Core Outputs

- `CURRENT_STATE.md`
- `ARCHITECTURE.md`
- `ROADMAP.md`
- `DECISIONS.md`
- `BUILD_LOG.md`
- `WEEKLY_REPORT.md`

## Quick Start

1. Copy the `obsidian_sync` folder into your repo.
2. Edit `obsidian_sync_config.json`.
3. Give `CODEX_OBSIDIAN_SYNC_TASK.md` to Codex.
4. Let Codex update the files in `exports/`.
5. Run the sync script from PowerShell:

```powershell
cd obsidian_sync/scripts
./sync_to_obsidian.ps1
```

## Designed For

- MicroGrow
- BioCalm
- New Earth Living
- New Earth Dashboard
- New Earth Website
- Omega OS
- Any future New Earth project
