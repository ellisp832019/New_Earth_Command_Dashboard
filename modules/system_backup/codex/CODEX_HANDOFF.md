# Codex Handoff: Build Backup Guardian Dashboard Module

Add this module into the New Earth Dashboard repo at:

```text
modules/system_backup
```

## Objective

Build a dashboard module called **Backup Guardian** that backs up the whole New Earth system.

The whole system source is:

```text
D:\
```

The first backup target is:

```text
E:\NEW_EARTH_BACKUP
```

## Build this first

1. Add module registration using `MODULE_MANIFEST.json`.
2. Add a dashboard page under Systems called **Backup Guardian**.
3. Read status from:

```text
modules/system_backup/runtime/latest_status.json
```

4. Add UI buttons:

- Dry Run
- Backup Now
- Verify Latest
- Restore Dry Run
- Open Backup Folder
- View Latest Report

5. Wire buttons to run the Windows scripts safely.

## Use these scripts

```text
scripts/windows/dry_run.bat
scripts/windows/backup_now.bat
scripts/windows/verify_latest.bat
scripts/windows/restore_dry_run.bat
```

These Windows wrappers resolve the module root internally, so they are safe to launch directly without first changing directories.

## Critical safety rules

- Do not delete anything from `D:\`.
- Do not restore over live files by default.
- Always use dry run for restore.
- Do not commit `config/backup_paths.local.json`.
- Use `backup_paths.local.json.example` as the template.
- Keep all backups local-first.

## Phase 1 acceptance criteria

- Dashboard shows backup health.
- Dry run works.
- Backup now works.
- Verify latest works.
- Restore dry run works.
- Latest status file updates.
- Reports are saved.
- Missing backup drive gives a clear red warning.

## Phase 2 now

The current build adds the first Phase 2 automation layer:

- scheduled daily backup
- weekly snapshot
- monthly archive
- backup history file
- retention settings
- freshness warnings
- restore point folders
- schedule and retention summaries
- next suggested run

## Phase 3 later

- Add checksum manifests.
- Add drive health checks.
- Add second/off-site drive support.
- Add deeper restore workflows.
