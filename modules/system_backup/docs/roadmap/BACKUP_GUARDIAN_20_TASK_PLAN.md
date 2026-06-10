# Backup Guardian - 20 Task Future Plan

This plan is the long runway for Backup Guardian.

Goal:

- get the guardian to a steady state where it should not need more work until New Earth genuinely expands
- keep everything local-first, calm, and review-first
- leave cloud, login, and heavy multi-drive complexity out until the expansion trigger is real

## Rules

- Finish one task at a time.
- Keep each task small enough to review safely.
- Prefer dashboard clarity over new machinery.
- Do not add expansion-only complexity until the baseline is already stable.
- If a task starts to grow beyond one clean slice, split it.

## Phase 1 - Lock The Core

Goal:

- make the existing backup flow feel coherent, trustworthy, and easy to read

Tasks:

### 1. Lock Scheduled Orchestration

- Make the existing daily, weekly, monthly, and quick actions feel like one coherent backup system.
- Keep the scheduler and manual buttons aligned.

### 2. Tighten Run State Summaries

- Make the status file and dashboard use the same wording for each run type.
- Keep green, amber, red, and grey states easy to read.

### 3. Finish the History Timeline

- Show newest backup events first.
- Make action, mode, state, duration, and finish time obvious at a glance.

### 4. Add History Filters

- Let Peter filter by run type and health state.
- Keep the history surface calm and local-only.

Exit criteria:

- the dashboard tells the truth at a glance
- the latest run is easy to understand
- recent history is easy to scan without opening files

## Phase 2 - Make It Self-Explaining

Goal:

- make restore points, verification, and warnings understandable without extra context

Tasks:

### 5. Add Restore Point Picking

- Let the dashboard choose a restore point without opening runtime files.
- Keep selection read-only for now.

### 6. Improve Restore Point Summaries

- Show kind, timestamp, source action, and report link more clearly.
- Keep the summaries easy to scan in an emergency.

### 7. Strengthen Manifest Verification

- Keep `Verify Latest` comparing the latest manifest fingerprint against the current target.
- Handle missing or incomplete manifest data cleanly.

### 8. Explain Verification Mismatches Better

- Make file count, size, path, and fingerprint differences easier to understand.
- Keep the failure wording specific and calm.

### 9. Refine Freshness Warnings

- Keep stale and overdue backups easy to spot.
- Make the warning thresholds obvious in the dashboard copy.

### 10. Add Calm Notifications

- Surface amber/red states as local dashboard banners.
- Keep the wording short and non-alarming.

Exit criteria:

- verification is clearly stronger than target-exists checking
- restore points are visible in the UI
- warnings feel calm, specific, and useful

## Phase 3 - Make It Operationally Complete

Goal:

- make the module useful day to day without needing helper tools

Tasks:

### 11. Track Backup Growth

- Show backup size trends over time.
- Make growth visible without needing a separate tool.

### 12. Improve Report Access

- Make the latest report easy to open.
- Keep recent report paths visible from the dashboard.

### 13. Make Folder Actions Context-Aware

- Keep open-folder actions aligned with the real mirror/root state.
- Use labels that tell Peter exactly where the click goes.

### 14. Tighten Retention Review

- Make prune rules and retention windows easy to understand.
- Keep old snapshot cleanup predictable.

### 15. Polish Restore Dry Run

- Make restore preview wording clearer.
- Keep the dry-run path safe, explicit, and easy to trust.

Exit criteria:

- the dashboard is enough to run and review the backup routine comfortably
- the main backup views are self-explanatory
- restore preview remains safe and non-destructive

## Phase 4 - Expansion Only

Goal:

- keep the module quiet until New Earth genuinely outgrows the current backup design

Tasks:

### 16. Add Expansion Triggers

- Define what "New Earth has outgrown the current backup design" means.
- Only unlock new complexity when the trigger is real.

### 17. Add Second Drive Support

- Support a larger or alternate backup target when the baseline drive is no longer enough.

### 18. Add Drive Rotation

- Allow local and off-site rotation only after a second drive exists.

### 19. Add Health and Hardening for New Hardware

- Add SMART or equivalent drive health visibility when new hardware is in play.
- Add encrypted archive support only if the expanded setup needs it.

### 20. Add Full Recovery Workflows

- Build the full restore wizard, disaster recovery playbook, and recovery scoring only when the expansion path is active.

Exit criteria:

- the current backup design stays stable until expansion is genuinely needed
- new hardware or off-site complexity only appears when the system demands it

## End State

After task 20, Backup Guardian should be at a maintenance-only stage for the current system shape.

At that point, the only meaningful future work should be triggered by one of these changes:

- New Earth grows enough to need a second drive
- off-site protection becomes necessary
- restore workflows need to become guided instead of preview-only
- hardware health monitoring becomes a real operational need

If none of those triggers are true, the module should stay quiet, stable, and done.
