# Backup Guardian - Master Roadmap

This is the single master roadmap for Backup Guardian.

Goal:

- keep Backup Guardian stable enough that it does not need more work until New Earth genuinely grows
- make the current backup system calm, readable, and low-maintenance
- keep expansion-only work parked until a real expansion trigger appears

## What Is Already Done

- Manual backup flow: Dry Run, Backup Now, Verify Latest, Restore Dry Run
- Scheduled actions: Quick Incremental, Daily Backup, Weekly Snapshot, Monthly Archive
- Manifest-backed verification for the latest backup
- Backup history timeline and recent run summaries
- Freshness warnings and calm health states
- Restore-point folders and summaries
- Latest report path and open-report access
- Context-aware open-folder behavior
- Backup size tracking in status

## What Is Still Worth Doing

These tasks are useful if you want the module to feel fully settled, but they are not required before the system can be left alone for a while.

| Priority | Area | Remaining Work | Why It Matters |
|---|---|---|---|
| Must-have | Orchestration | Tighten scheduled orchestration wording and flow | Keeps manual and scheduled actions coherent |
| Must-have | State | Tighten run state summaries | Makes the dashboard tell the truth at a glance |
| Must-have | History | Finish the history timeline and add filters | Makes review faster without opening files |
| Must-have | Verification | Strengthen manifest verification and explain mismatches better | Confirms the latest backup is really the latest backup |
| Must-have | Warnings | Refine freshness warnings and add calm notifications | Surfaces stale backups before they become a problem |
| Must-have | Restore preview | Polish restore dry run | Keeps the safety path clear and trustworthy |
| Must-have | Restore points | Add restore point picking and improve summaries | Reduces friction during review or recovery |
| Should-have | Growth tracking | Show backup size trends over time | Helps understand how fast New Earth is expanding |
| Should-have | Reports | Make report access quicker and easier to scan | Saves time during review |
| Should-have | Retention | Tighten retention review | Prevents surprise cleanup behavior |

## What Stays Parked

These should not be started until New Earth truly outgrows the current backup design.

| Area | Parked Work | Why It Stays Parked |
|---|---|---|
| Expansion triggers | Add expansion triggers | Only needed when the system shape changes |
| Hardware | Second drive support | Not needed until the current target is no longer enough |
| Hardware | Drive rotation | Depends on having more than one real target |
| Hardware | Health and hardening for new hardware | Only matters when new hardware is introduced |
| Recovery | Full recovery workflows | Better held until the expansion path is active |
| Off-site | Off-site complexity | Not needed for the current system shape |

## Priority Order

If the goal is to leave Backup Guardian alone until the system grows, the practical order is:

1. Finish the must-have items
2. Optionally finish the should-have items
3. Leave parked work alone until an expansion trigger becomes real

## Expansion Triggers

Only unlock the parked work if at least one of these becomes true:

- the current backup target is too small
- off-site protection is now required
- restore workflows need to become guided instead of preview-only
- hardware health monitoring has become a real operational need

## 20 Task Runway

If you want the longer delivery shape, use these four phases:

### Phase 1 - Lock The Core

Tasks:

1. Lock scheduled orchestration
2. Tighten run state summaries
3. Finish the history timeline
4. Add history filters

Exit:

- the dashboard tells the truth at a glance
- the latest run is easy to understand
- recent history is easy to scan without opening files

### Phase 2 - Make It Self-Explaining

Tasks:

5. Add restore point picking
6. Improve restore point summaries
7. Strengthen manifest verification
8. Explain verification mismatches better
9. Refine freshness warnings
10. Add calm notifications

Exit:

- verification is clearly stronger than target-exists checking
- restore points are visible in the UI
- warnings feel calm, specific, and useful

### Phase 3 - Make It Operationally Complete

Tasks:

11. Track backup growth
12. Improve report access
13. Make folder actions context-aware
14. Tighten retention review
15. Polish restore dry run

Exit:

- the dashboard is enough to run and review the backup routine comfortably
- the main backup views are self-explanatory
- restore preview remains safe and non-destructive

### Phase 4 - Expansion Only

Tasks:

16. Add expansion triggers
17. Add second drive support
18. Add drive rotation
19. Add health and hardening for new hardware
20. Add full recovery workflows

Exit:

- the current backup design stays stable until expansion is genuinely needed
- new hardware or off-site complexity only appears when the system demands it

## End State

After task 20, Backup Guardian should be at a maintenance-only stage for the current system shape.

If none of the expansion triggers are true, the module should stay quiet, stable, and done.

That is the finish line.

## Supporting Docs

These files remain available for detail, but the master roadmap is the main reference:

- `BACKUP_GUARDIAN_ENDGAME.md`
- `BACKUP_GUARDIAN_STATUS_TABLE.md`
- `BACKUP_GUARDIAN_PRIORITY_MATRIX.md`
- `BACKUP_GUARDIAN_20_TASK_PLAN.md`
- `V1_V2_V3_ROADMAP.md`
- `FUTURE_WORK_REGISTER.md`
- `PHASE_GATES.md`
- `COMMIT_TREE_AND_NEXT_STEPS.md`
