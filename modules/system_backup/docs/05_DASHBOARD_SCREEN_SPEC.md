# Dashboard Screen Spec

## Page title

Backup Guardian

## Section

Systems

## Status cards

- Source Drive
- Backup Drive
- Last Backup
- Last Verification
- Backup Size
- Backup Health
- Warnings
- Restore Test Status
- Schedule Summary
- Retention Summary
- Freshness Summary
- Restore Points

## Main actions

- Dry Run
- Backup Now
- Verify Latest
- Restore Dry Run
- Open Backup Folder
- Export Report
- Daily Backup
- Weekly Snapshot
- Monthly Archive
- Refresh Status

## Activity log

Show:

- start time
- end time
- duration
- files scanned
- files copied
- files skipped
- warnings
- errors

Also show:

- latest status file
- backup history file
- next suggested run

## Health states

```text
GREEN  = latest backup verified
AMBER  = backup old or unverified
RED    = backup failed or target missing
GREY   = never run
```
