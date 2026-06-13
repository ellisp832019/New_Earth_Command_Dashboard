# Security Review — Obsidian Sync

## Permission posture

Default permissions should be disabled until explicitly enabled.

## Requested permissions

- file_read
- file_write_project_only
- vault_access
- scheduled_sync

## Review notes

No backend control should be enabled during the first UI shell phase.
