# Backup Guardian Roadmap: V1, V2 and V3

This roadmap is part of the module so Codex understands the long-term direction.

## V1 - Build Now: Safe Manual Backup

V1 is the immediate build.

Goal:

```text
Protect D:\ as the full New Earth system.
```

V1 features:

- Dashboard page: Backup Guardian
- Source: `D:\`
- Target: external backup drive, for example `E:\NEW_EARTH_BACKUP`
- Manual Dry Run
- Manual Backup Now
- Manual Verify Latest
- Manual Restore Dry Run
- Backup reports
- Runtime status file
- Clear dashboard health state
- Safe exclude policy
- No cloud dependency
- No automatic deletion of source files
- No live restore overwrite

V1 is the priority.

## V2 - Automation and Intelligence

V2 adds scheduled and smarter backup behaviour.

V2 features:

- Quick incremental backup
- Scheduled daily backup
- Weekly snapshot
- Monthly archive
- Retention policy
- Backup history database
- Backup duration tracking
- Backup size tracking
- File count tracking
- Better verification
- Optional checksum manifest
- Warning if backup drive has not been connected
- Warning if backup is older than chosen threshold
- Dashboard timeline of backup events
- Restore point list
- Notification banner inside dashboard

Current build status:

- Quick incremental backup is wired for new and changed files only.
- Daily, weekly, and monthly actions are now wired.
- Backup history is written to `modules/system_backup/runtime/backup_history.json`.
- The dashboard now surfaces schedule, retention, freshness, and restore-point summaries.
- Checksum manifests and deeper verification remain future work.

V2 should only be started after V1 is stable.

## V3 - Disaster Recovery System

V3 turns Backup Guardian into a full New Earth disaster recovery system.

V3 features:

- Multi-drive backup support
- Off-site backup drive rotation
- Encrypted archive option
- Deep checksum verification
- SMART drive health monitoring
- Drive failure warnings
- Full restore wizard
- Project-level restore wizard
- Omega OS restore wizard
- Repo restore wizard
- Obsidian vault restore wizard
- Restore simulation report
- Disaster recovery checklist
- Emergency rebuild guide
- Backup integrity score
- Optional NAS/Linux backup target support

V3 should only be started after V2 is stable.

## Build Rule

Codex should build in this order:

```text
V1 first.
V2 later.
V3 last.
```

Do not mix V2/V3 complexity into V1 unless it is harmless documentation or placeholder structure.
