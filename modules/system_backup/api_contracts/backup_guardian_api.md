# Backup Guardian API Contract

The dashboard can call local commands or wrap them through its backend.

## Actions

### Dry run

```http
POST /api/modules/system-backup/dry-run
```

### Backup now

```http
POST /api/modules/system-backup/backup-now
```

### Verify latest

```http
POST /api/modules/system-backup/verify-latest
```

### Restore dry run

```http
POST /api/modules/system-backup/restore-dry-run
```

### Status

```http
GET /api/modules/system-backup/status
```

## Status response

```json
{
  "module": "system_backup",
  "state": "green",
  "last_backup_at": "2026-06-07T05:00:00Z",
  "last_verify_at": "2026-06-07T05:30:00Z",
  "source": "D:/",
  "target": "E:/NEW_EARTH_BACKUP",
  "summary": "Latest backup verified",
  "warnings": [],
  "errors": []
}
```
