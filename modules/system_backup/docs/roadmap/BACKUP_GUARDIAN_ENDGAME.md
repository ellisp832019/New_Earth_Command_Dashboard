# Backup Guardian - Endgame

This page is the simplest summary of where Backup Guardian is headed.

Goal:

- keep the current backup guardian stable enough to leave alone
- make it obvious what is already done
- make it obvious what should stay parked until New Earth grows

## Already Done

- Manual backup flow: Dry Run, Backup Now, Verify Latest, Restore Dry Run
- Scheduled actions: Quick Incremental, Daily Backup, Weekly Snapshot, Monthly Archive
- Manifest-backed verification for the latest backup
- Backup history timeline and recent run summaries
- Freshness warnings and calm health states
- Restore-point folders and summaries
- Latest report path and open-report access
- Context-aware open-folder behavior
- Backup size tracking in status

## Still Worth Doing

These are useful, but not required if the goal is to leave the module quiet until growth demands more work.

- Tighten run state copy if wording needs a final polish
- Explain verification mismatches more clearly
- Add filters to the history timeline
- Let the dashboard pick a restore point directly
- Add local amber/red banners for important warnings
- Show backup size trends over time
- Make report opening quicker
- Make pruning rules easier to scan
- Polish restore dry-run wording

## Parked Until Expansion

Do not start these until New Earth genuinely outgrows the current backup design.

- Second drive support
- Drive rotation
- Health and hardening for new hardware
- Full recovery workflows
- Any off-site complexity

## Expansion Triggers

Only unlock the parked work if at least one of these becomes true:

- the current backup target is too small
- off-site protection is now required
- restore workflows need to become guided instead of preview-only
- hardware health monitoring has become a real operational need

## End State

If none of the expansion triggers are true, Backup Guardian should stay in maintenance mode and should not need more work for the current system shape.

That is the desired finish line.
