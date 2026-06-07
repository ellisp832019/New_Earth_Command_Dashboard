# Test Plan

## Test 1: Config loads

- Copy example config to local config.
- Confirm paths load.

## Test 2: Dry run

- Run `scripts/windows/dry_run.bat`.
- Confirm no files are copied.
- Confirm report is created.
- Confirm latest_status.json is updated.

## Test 3: Backup now

- Run `scripts/windows/backup_now.bat`.
- Confirm files copy to target.
- Confirm excluded folders are skipped.

## Test 4: Verify latest

- Run `scripts/windows/verify_latest.bat`.
- Confirm target exists.

## Test 5: Restore dry run

- Run `scripts/windows/restore_dry_run.bat`.
- Confirm no files overwrite live source.
