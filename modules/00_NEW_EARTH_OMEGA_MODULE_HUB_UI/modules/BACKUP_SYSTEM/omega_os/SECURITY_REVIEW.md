# Security Review — Backup System

## Permission posture

Default permissions should be disabled until explicitly enabled.

## Requested permissions

- file_read
- file_write_backup_target
- scheduled_tasks
- system_health

## Review notes

No backend control should be enabled during the first UI shell phase.
