# Future Work Register

See also:

- `COMMIT_TREE_AND_NEXT_STEPS.md` for commit-sized backup guardian slices and the next-step plan.

## V2 Backlog

### Already landed in the tree

- Scheduled daily, weekly, monthly, and quick backup actions
- Backup history file and dashboard history surface
- Backup age warnings and freshness summaries
- Backup size tracking
- Retention rules
- Checksum manifest support
- Restore point summaries

### Remaining V2 backlog

| ID | Feature | Priority | Notes |
|---|---|---:|---|
| BG-V2-001 | Scheduled backup orchestration | High | Task Scheduler or dashboard scheduler for the existing actions |
| BG-V2-004 | Backup history database | Medium | Optional SQLite upgrade for richer querying later |
| BG-V2-009 | Restore point picker | Medium | Let the user select a restore point from the UI |
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
