# New Earth Dashboard Module: Backup Guardian

This is a full dashboard module pack for backing up the entire New Earth system.

The source of truth is:

```text
D:\
```

Because your `D:\` drive is the whole New Earth system.

## Drop-in location

Place this folder here inside the New Earth Dashboard repo:

```text
modules/system_backup
```

## What it protects

- Entire `D:\` drive
- New Earth Dashboard
- MicroGrow
- New Earth Living
- BioCalm
- Obsidian Vault
- NEW_EARTH_OMEGA_OS_PACK
- Documents
- Images
- Videos
- Meeting files
- Project assets
- Future repos and systems

## First target

Use your 500GB external drive now:

```text
E:\NEW_EARTH_BACKUP
```

Later upgrade to a 2TB SSD.

## Dashboard buttons

- Dry Run
- Backup Now
- Verify Latest Backup
- Restore Dry Run
- Open Backup Folder
- View Backup Report

## Build order

1. Add this module to the dashboard repo.
2. Copy `config/backup_paths.local.json.example` to `config/backup_paths.local.json`.
3. Edit paths for your PC.
4. Run dry run.
5. Run first backup.
6. Verify backup.
7. Connect status file to dashboard UI.

## Local status file

The dashboard should read:

```text
modules/system_backup/runtime/latest_status.json
```


## Roadmap included

This module now includes V2 and V3 as future work.

Read:

```text
docs/roadmap/V1_V2_V3_ROADMAP.md
docs/roadmap/FUTURE_WORK_REGISTER.md
docs/roadmap/PHASE_GATES.md
codex/CODEX_V2_V3_FUTURE_WORK_ADDENDUM.md
```

Build rule:

```text
V1 = build now
V2 = automation later
V3 = disaster recovery later
```
