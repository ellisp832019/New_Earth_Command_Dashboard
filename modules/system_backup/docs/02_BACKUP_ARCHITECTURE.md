# Backup Architecture

## Source

```text
D:\
```

## Target

```text
E:\NEW_EARTH_BACKUP
```

## Backup target structure

```text
E:\NEW_EARTH_BACKUP
|-- mirror
|-- daily
|-- weekly
|-- monthly
|-- manifests
|-- reports
|-- restore_tests
|-- latest_status.json
|-- backup_history.json
```

## Phase 1

Manual, safe, simple:

- Dry Run
- Backup Now
- Verify Latest
- Restore Dry Run

Windows entry points:

- `scripts/windows/dry_run.bat`
- `scripts/windows/backup_now.bat`
- `scripts/windows/verify_latest.bat`
- `scripts/windows/restore_dry_run.bat`

These wrappers resolve the module root internally, so they can be run directly without changing the current directory first.

## Phase 2

Dashboard-controlled scheduling:

- Daily backup
- Weekly snapshot
- Monthly archive
- Backup history
- Retention rules
- Freshness warnings
- Restore point list
- Schedule summary

Phase 2 runtime data:

- `modules/system_backup/runtime/latest_status.json`
- `modules/system_backup/runtime/backup_history.json`

Phase 2 restore-point folders:

- `E:\NEW_EARTH_BACKUP\daily`
- `E:\NEW_EARTH_BACKUP\weekly`
- `E:\NEW_EARTH_BACKUP\monthly`

## Phase 3

Disaster recovery:

- Multiple drives
- Off-site copy
- Encrypted archive
- Full restore wizard
- Health warnings
