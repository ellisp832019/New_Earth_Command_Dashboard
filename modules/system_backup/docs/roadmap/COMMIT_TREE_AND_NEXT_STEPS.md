# Backup Guardian Commit Tree And Next Steps

This note groups the current Backup Guardian work into commit-sized slices and lays out the next safe follow-on plan.

## Current Commit Tree

### 1. Foundation And Shell

- `c72c82e` Add Backup Guardian systems module
- `7bb2276` Soften missing backup drive state
- `3ab000a` Soften printer and backup status panels
- `16c4f5d` Expand the Systems hub

What this slice established:

- module registration
- initial dashboard placement
- calm backup status presentation
- safe empty-state handling

### 2. Phase 2 Automation

- `b95aa9f` feat(backup): add phase 2 automation

What this slice established:

- daily backup
- weekly snapshot
- monthly archive
- backup history file
- freshness summaries
- restore-point summaries

### 3. Quick Incremental Mode

- `57267dc` feat(backup): add quick incremental mode

What this slice established:

- faster delta-based backup flow
- a clearer manual action for day-to-day use
- a bridge between manual backup and scheduled automation

### 4. Current Working Tree Group

Current uncommitted backup guardian work is clustered into:

- Flutter backup guardian screen polish
- Windows wrapper harmonisation for manual and scheduled actions
- status and launch message cleanup

This is the right size for the next commit series.

## Recommended Next Commit Order

### Commit A: UI Polish And State Sync

Goal:

- keep the dashboard calm and readable
- make the state cards reflect current backup data more clearly

Include:

- better status card spacing
- clearer labels for last backup, verification, and restore test
- refresh triggers after actions complete

### Commit B: Activity And History Surface

Goal:

- make recent backup activity easier to review
- keep restore points visible without opening files manually

Include:

- recent activity list refinement
- restore-point summaries
- next suggested run messaging

### Commit C: Health And Warning Rules

Goal:

- make backup risk visible before a failure happens

Include:

- backup age warnings
- missing-target warnings
- backup-size tracking summaries
- amber/red/grey state tuning

### Commit D: Verification And Integrity

Goal:

- raise trust in the backup before any restore is attempted

Include:

- checksum manifest support
- stronger verification summaries
- clearer failed-check messaging

### Commit E: Restore Safety

Goal:

- keep restore testing safe and explicit

Include:

- restore dry-run flow refinement
- restore point selection UX
- safer report wording for preview restores

### Commit F: V3 Readiness

Goal:

- prepare the module for the next disaster recovery phase without mixing the phase too early

Include:

- multi-drive planning surfaces
- SMART health visibility
- drive rotation notes
- recovery playbook expansion

## Working Rule For Later Commits

- Keep each commit scoped to one visible behaviour change.
- Keep shell scripts and dashboard UI in separate commits when possible.
- Keep V2 automation and V3 disaster recovery separate.
- Prefer state/readout improvements before adding new destructive or recovery actions.

## Practical Next Step

Start with Commit A and Commit B together only if the UI state wiring stays small and reviewable. If the screen grows too much, split them immediately.

