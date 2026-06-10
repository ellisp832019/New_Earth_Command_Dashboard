# Backup Guardian - Current State And Remaining Work

This table shows what Backup Guardian already does and what is still worth doing.

Goal:

- make it easy to see what is finished
- make it easy to see what is still useful
- keep expansion-only work parked until New Earth actually grows beyond the current design

## Current State

| Area | Already in place | Notes |
|---|---|---|
| Manual backup flow | Dry Run, Backup Now, Verify Latest, Restore Dry Run | Core safe path is present |
| Scheduled actions | Quick Incremental, Daily Backup, Weekly Snapshot, Monthly Archive | The automation actions are wired |
| Verification | Manifest-backed Verify Latest | Latest manifest fingerprint is compared against the current target |
| History | Backup history file and dashboard timeline surface | Recent events can be reviewed locally |
| Freshness | Backup age warnings and calm health states | Stale backups are visible |
| Restore points | Restore-point folders and summaries | Restore candidates are visible without opening raw files |
| Reports | Latest report path and open-report access | The latest report is surfaced from the dashboard |
| Folder actions | Context-aware open-folder behavior | The UI opens the mirror when available, otherwise the backup root |
| Backup size | Backup size is tracked in status | Growth is visible in the dashboard |

## Remaining Work

| Priority | Area | Still worth doing | Why it remains useful |
|---|---|---|---|
| Must-have | Run state copy | Tighten the wording in the status surface if needed | Keeps the dashboard calm and obvious |
| Must-have | Verification details | Explain mismatches more clearly when something is off | Makes support and review easier |
| Must-have | History review | Add filters to the timeline | Helps Peter find the right run faster |
| Must-have | Restore point picking | Let the dashboard choose a restore point directly | Reduces friction in an emergency |
| Must-have | Notifications | Add local amber/red banners | Keeps important warnings visible |
| Should-have | Growth tracking | Show backup size trends over time | Helps understand how fast New Earth is expanding |
| Should-have | Report access | Make report opening even quicker | Saves time during review |
| Should-have | Retention review | Make pruning rules easier to scan | Prevents surprise cleanup behavior |
| Should-have | Restore dry run polish | Keep the preview wording clear and safe | Preserves trust in the non-destructive path |
| Expansion-only | Second drive support | Only when the current backup target is no longer enough | Not needed for the current system shape |
| Expansion-only | Drive rotation | Only after a second drive exists | Depends on expanded hardware |
| Expansion-only | Health and hardening | Only when new hardware becomes part of the setup | Not required yet |
| Expansion-only | Full recovery workflows | Only when guided restore becomes a real need | Best left parked until expansion is real |

## Readout

If the goal is "leave Backup Guardian alone until New Earth grows", the practical answer is:

1. Keep the current state as-is.
2. Only finish the must-have remaining work if you want the module to feel fully settled.
3. Leave the expansion-only work parked until the trigger is real.

## Expansion Trigger

Do not start the expansion-only work unless at least one of these is true:

- the current backup target is too small
- off-site protection is now required
- restore workflows need to become guided instead of preview-only
- hardware health monitoring has become a real operational need

If none of those are true, the module is already close to the steady-state finish line.
