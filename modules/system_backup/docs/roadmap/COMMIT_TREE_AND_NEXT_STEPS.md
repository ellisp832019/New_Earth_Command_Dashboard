# Backup Guardian Commit Tree And Next Steps

This note groups the current Backup Guardian work into commit-sized slices and lays out the next safe follow-on plan.

## Status

Complete. The current backup guardian slice is now in the tree and has been verified with a fresh backup run.

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

### 4. Completed Working Tree Slice

The last backup guardian slice in this pass has been closed out and folded into the tree:

- Flutter backup guardian screen polish
- Windows wrapper harmonisation for manual and scheduled actions
- status and launch message cleanup

This is now the baseline for the next backup guardian pass.

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

## Practical Next Task Slice

If we are choosing the next real backup guardian direction, the best slice is a small V2 integrity pack:

### Task 1: Add checksum manifest support

Goal:

- make each backup produce a verifiable local manifest

Deliverables:

- write a checksum or file fingerprint manifest during backup completion
- store the manifest alongside the existing report and restore-point data
- keep the feature optional if the manifest setting is disabled

Implementation checklist:

1. Define the manifest contract for the current backup mode.
- Keep the manifest local and sidecar-based.
- Include the action, backup kind, timestamps, source and target paths, file counts, and size summaries.
- Add checksum or fingerprint data for the files the backup actually copied or inspected.

2. Reuse the existing manifest write path where possible.
- Keep the manifest writer in the backup guardian script or shared backup module.
- Avoid introducing a separate persistence format unless the current JSON shape is insufficient.
- Make sure the manifest path is recorded in status and history output.

3. Make the feature optional and safe by default.
- Respect the existing manifest setting if it is already present.
- If the setting is off, skip manifest generation without failing the backup.
- If manifest creation fails, surface a warning or failure that does not hide the backup result.

4. Add verification hooks that can read the manifest later.
- Ensure `Verify Latest` can detect whether a manifest exists for the newest backup.
- Prepare the manifest structure so later verification can compare it against the target state.

Acceptance criteria:

- A successful backup can produce a manifest file in the expected local location.
- The manifest includes enough metadata to explain what backup ran and when it ran.
- The backup still succeeds if manifest generation is disabled.
- The backup still reports clearly if manifest generation fails.
- The manifest path appears in backup status or history outputs.

Non-goals:

- Do not build the full restore wizard yet.
- Do not add multi-drive rotation yet.
- Do not add cloud or network sync behavior.

### Task 2: Strengthen verification

Goal:

- make `Verify Latest` confirm more than "the target exists"

Deliverables:

- compare the latest backup metadata against the current target
- report clearer success, warning, and failure reasons
- surface manifest presence or absence in the status output

### Task 3: Add a backup history review surface

Goal:

- let the dashboard show recent backup activity without opening runtime files

Deliverables:

- show the newest backup history entries in the backup guardian UI
- highlight action, mode, state, duration, and finished time
- keep the list read-only and local-first

### Task 4: Add freshness warnings

Goal:

- make stale backups easy to notice

Deliverables:

- flag missing, old, or overdue backups in amber/red
- keep the warning wording calm and specific
- reuse the existing status state model

### Task 5: Surface restore points more directly

Goal:

- make restore-point discovery easier before a full restore wizard exists

Deliverables:

- show the most recent restore points in the UI
- let the user see backup kind, timestamp, and source action
- keep selection and restore execution out of scope for this slice

## Suggested Execution Order

1. Task 1
2. Task 2
3. Task 3
4. Task 4
5. Task 5

## Scope Guardrail

- Do not start the full restore wizard yet.
- Do not add multi-drive or off-site complexity yet.
- Keep each task reviewable on its own if the slice starts to grow.

## Immediate Next 3 Task Plan

If we are doing the next three follow-on slices, keep the order tight:

### Task 1: Backup History Timeline

Goal:

- make recent backup activity easy to review in the dashboard

Deliverables:

- show the newest backup events first
- surface action, mode, state, duration, and finish time clearly
- keep the timeline calm, local-first, and read-only

### Task 2: Freshness Warnings

Goal:

- make stale or missing backups easy to spot before a problem grows

Deliverables:

- flag overdue backups in amber or red
- reuse the current status and history data
- keep the wording calm and specific

### Task 3: Manifest Hardening

Goal:

- make checksum-based verification faster, clearer, and more dependable

Deliverables:

- tighten the manifest comparison rules
- separate manifest-backed verification from basic target existence checks
- keep older manifest records working safely

### Suggested Delivery Order

1. Task 1
2. Task 2
3. Task 3

### Stop Rule

- If any task starts to grow beyond a small commit-sized slice, stop and split it.
- Do not mix V3 recovery work into these three tasks.
