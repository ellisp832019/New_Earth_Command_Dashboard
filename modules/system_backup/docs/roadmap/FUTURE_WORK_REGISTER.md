# Future Work Register

See also:

- `COMMIT_TREE_AND_NEXT_STEPS.md` for commit-sized backup guardian slices and the next-step plan.

## V2 Backlog

| ID | Feature | Priority | Notes |
|---|---|---:|---|
| BG-V2-001 | Scheduled daily backups | High | Windows Task Scheduler or dashboard scheduler |
| BG-V2-002 | Weekly snapshots | High | Snapshot folder with date stamp |
| BG-V2-003 | Monthly archives | Medium | Long-term restore points |
| BG-V2-004 | Backup history database | High | SQLite or dashboard local DB |
| BG-V2-005 | Backup age warnings | High | Dashboard amber/red states |
| BG-V2-006 | Backup size tracking | Medium | Track growth of New Earth system |
| BG-V2-007 | Retention rules | Medium | Keep daily/weekly/monthly windows |
| BG-V2-008 | Checksum manifest | High | Verify important files |
| BG-V2-009 | Restore point list | Medium | Select restore point from UI |
| BG-V2-010 | Dashboard notifications | Medium | Local warning banners |

## V3 Backlog

| ID | Feature | Priority | Notes |
|---|---|---:|---|
| BG-V3-001 | Multiple backup drives | High | 500GB now, 2TB later, off-site drive |
| BG-V3-002 | Drive rotation | High | Local + off-site copy |
| BG-V3-003 | Encrypted archive | Medium | For sensitive off-site copy |
| BG-V3-004 | SMART health monitoring | High | Warn before drive failure |
| BG-V3-005 | Full restore wizard | High | Guided recovery |
| BG-V3-006 | Project restore wizard | High | Restore MicroGrow, Dashboard, BioCalm etc |
| BG-V3-007 | Obsidian vault restore wizard | High | Recover knowledge base safely |
| BG-V3-008 | Omega OS restore wizard | High | Recover `NEW_EARTH_OMEGA_OS_PACK` |
| BG-V3-009 | Disaster recovery playbook | High | Step-by-step emergency document |
| BG-V3-010 | Backup integrity score | Medium | Green/amber/red confidence score |
| BG-V3-011 | NAS/Linux target | Low | Later expansion |
