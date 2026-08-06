# Backup Guardian - Priority Matrix

This matrix ranks the remaining Backup Guardian work by importance.

Goal:

- finish the core backup guardian so it can sit quietly until New Earth grows
- keep the current system stable, readable, and low-maintenance
- separate "must do now" work from "only when the system expands" work

## Priority Key

- Must-have: needed to make the current backup guardian feel finished and trustworthy
- Should-have: valuable for day-to-day clarity, but not required for the steady-state goal
- Expansion-only: should stay parked until New Earth actually outgrows the current design

## Must-Have

| Area | Task | Why it matters |
|---|---|---|
| Orchestration | Lock scheduled orchestration | Keeps manual and scheduled backup actions coherent |
| State | Tighten run state summaries | Makes the dashboard tell the truth at a glance |
| History | Finish the history timeline | Lets Peter review the latest run without opening files |
| Verification | Strengthen manifest verification | Confirms the latest backup is actually the latest backup |
| Verification | Explain verification mismatches better | Makes failures understandable and calm |
| Warnings | Refine freshness warnings | Surfaces stale backups before they become a problem |
| Warnings | Add calm notifications | Keeps amber/red states visible without drama |
| Folder actions | Make folder actions context-aware | Prevents clicks from leading to the wrong place |
| Restore preview | Polish restore dry run | Keeps the safety path clear and trustworthy |

## Should-Have

| Area | Task | Why it matters |
|---|---|---|
| History | Add history filters | Makes review faster without changing the core backup |
| Restore points | Add restore point picking | Reduces friction when reviewing restore candidates |
| Restore points | Improve restore point summaries | Makes emergency scanning easier |
| Growth tracking | Track backup growth | Helps understand how quickly New Earth is expanding |
| Reports | Improve report access | Makes the latest report easy to open |
| Retention | Tighten retention review | Keeps pruning understandable and predictable |

## Expansion-Only

| Area | Task | Why it stays parked |
|---|---|---|
| Expansion triggers | Add expansion triggers | Only needed when the system shape changes |
| Hardware | Add second drive support | Not needed until the baseline drive is no longer enough |
| Hardware | Add drive rotation | Depends on having more than one real target |
| Hardware | Add health and hardening for new hardware | Only matters when new hardware is introduced |
| Recovery | Add full recovery workflows | Better held until the expansion path is active |

## Readout

If the goal is "do not touch Backup Guardian again until New Earth grows", the right finishing order is:

1. Must-have tasks
2. Should-have tasks
3. Expansion-only tasks only when the trigger is real

## Recommended Rule

Do not start any expansion-only work unless at least one of these is true:

- the current backup target is too small
- off-site protection is now required
- restore workflows need to become guided instead of preview-only
- hardware health monitoring has become a real operational need

If none of those are true, keep the module quiet and let it run.
