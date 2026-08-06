# Test Plan

## Test 1: Config loads

- Copy example config to local config.
- Confirm paths load.
- On Windows, launch the batch wrappers directly from `scripts/windows/*.bat`; they resolve the module root internally.

## Test 2: Dry run

- Run `scripts/windows/dry_run.bat`.
- Confirm live progress appears in the console window while the report is also written to disk.
- Confirm no files are copied.
- Confirm report is created.
- Confirm latest_status.json is updated.

## Test 3: Backup now

- Run `scripts/windows/backup_now.bat`.
- Confirm live progress appears in the console window while the report is also written to disk.
- Confirm files copy to target.
- Confirm excluded folders are skipped.

## Test 4: Verify latest

- Run `scripts/windows/verify_latest.bat`.
- Confirm target exists.
- Confirm the dashboard shows the fresh verification banner or status message.
- Confirm the verify button changes to the filled fresh state after a successful verification.

## Test 5: Restore dry run

- Run `scripts/windows/restore_dry_run.bat`.
- Confirm no files overwrite live source.

## Test 6: Phase 2 automation

- Run `scripts/windows/setup_scheduled_backups.bat`.
- Run `scripts/windows/verify_scheduled_backups.bat`.
- Run `scripts/windows/quick_incremental.bat`.
- Run `scripts/windows/daily_backup.bat`.
- Run `scripts/windows/weekly_snapshot.bat`.
- Run `scripts/windows/monthly_archive.bat`.
- Confirm the Windows Task Scheduler entries are created for the daily, weekly, and monthly actions.
- Confirm `modules/system_backup/runtime/scheduler_status.json` is written after setup and verify.
- Confirm `modules/system_backup/runtime/backup_history.json` updates.
- Confirm the quick incremental run preserves deleted source files in the target mirror.
- Confirm restore point folders are created under `E:\NEW_EARTH_BACKUP\daily`, `weekly`, and `monthly`.
- Confirm the dashboard shows schedule, retention, freshness, and restore point summaries.
