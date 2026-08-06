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
- Daily Backup
- Weekly Snapshot
- Monthly Archive
- Quick Incremental
- Setup Scheduler
- Verify Scheduler
- Refresh Status

## Build order

1. Add this module to the dashboard repo.
2. Copy `config/backup_paths.local.json.example` to `config/backup_paths.local.json`.
3. Edit paths for your PC.
4. Run the Windows wrapper directly from `scripts/windows/dry_run.bat`.
5. Run first backup.
6. Verify backup.
7. Connect status file to dashboard UI.

The Windows wrappers resolve the module root explicitly, so they can be launched without changing the current working directory first.

## Local status file

The dashboard should read:

```text
modules/system_backup/runtime/latest_status.json
```

## Backup history

The current build writes a history file that the dashboard can use to show recent backup activity and restore points:

```text
modules/system_backup/runtime/backup_history.json
```

This history is used to surface:

- recent backup events
- backup age warnings
- next suggested run
- schedule and retention summaries
- manifest-backed verification results
- restore point entries under `E:\NEW_EARTH_BACKUP`


## Roadmap included

This module now includes V2 and V3 planning documents.

Read:

```text
docs/roadmap/BACKUP_GUARDIAN_MASTER_ROADMAP.md
docs/roadmap/BACKUP_GUARDIAN_ENDGAME.md
docs/roadmap/BACKUP_GUARDIAN_STATUS_TABLE.md
docs/roadmap/BACKUP_GUARDIAN_PRIORITY_MATRIX.md
docs/roadmap/BACKUP_GUARDIAN_20_TASK_PLAN.md
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

## Phase 2 now included

The current module build adds the first Phase 2 automation layer:

- daily backup
- quick incremental backup
- weekly snapshot
- monthly archive
- local Windows Task Scheduler setup for the timed backup actions
- local scheduler verification written to `runtime/scheduler_status.json`
- backup history file
- retention settings
- freshness warnings
- restore point listing
- checksum-manifest-backed verification
