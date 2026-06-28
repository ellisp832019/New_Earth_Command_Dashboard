# Major Upgrade Plan

This file extends the core FSD with a practical upgrade order for the app as it exists now.

It is meant to answer one question clearly:

What should we upgrade next across the whole Dashboard without losing the calm, local-first shape of the product?

## Purpose

The app is no longer a small shell.
It now has a real operating surface across:

- Dashboard
- Tasks
- Planner
- Projects
- Journal
- Inbox
- Learning
- Content
- Business
- Wellbeing
- Treasury
- Assets and QR labels
- Users & Devices Control
- Company Command Centre
- Omega Knowledge Engine
- Voice and voice intelligence
- Visual capture
- Backup/systems
- Module Hub / More

That means future work should not be chosen screen by screen in isolation.
It should be chosen as upgrade streams with clear dependencies, safety gates, and release value.

## Current Build Position

The app currently has a strong local-first base:

- local storage is working
- the app shell is stable
- major module routes are in place
- the release-readiness pass is healthy
- widget, analyzer, and Windows build verification are already part of the working rhythm

The app is strongest today in these areas:

1. daily local dashboard loop
2. assets and QR workflow
3. treasury and guided finance flow
4. users/devices access model
5. company read-only ops surfaces
6. knowledge-engine shell and repo intelligence direction

The app is still comparatively immature in these areas:

1. inbox processing depth
2. upgrade-safe write-back flows
3. stronger admin and reporting layers
4. unified repo-wide health visibility
5. integration adapters for external services

## Upgrade Rules

Every major upgrade should follow these rules:

1. Keep local-first as the default.
2. Prefer read-only and review-first before write-back.
3. Harden one operating loop at a time.
4. Do not let support modules make the dashboard noisy.
5. Keep route protection and data safety ahead of convenience.
6. Add tests, analyzer checks, and Windows build checks as part of the slice.

## Recommended Upgrade Order

This is the recommended repo-wide order for major upgrades.

### 1. Core Daily Loop Completion

Goal:
Finish the main personal operating loop so the app is dependable every day.

Focus:

- inbox processing foundation
- planner review completion
- task/project handoff polish
- clearer daily close and tomorrow-focus loop

Why first:
This is still the heart of the product.
If the daily loop is incomplete, other advanced modules stay secondary.

Done looks like:

- inbox items can be triaged calmly
- planner review persists cleanly
- today-to-tomorrow handoff feels complete
- dashboard still answers “what should I do next?”

### 2. Users & Devices Security Hardening

Goal:
Move Users & Devices from a strong demo and guided local system into a trusted operator layer.

Focus:

- onboarding readiness
- per-user PIN governance
- recovery workflow
- trust review queue
- approval visibility
- grouped audit reporting

Why now:
This module is already influencing route protection, treasury access, and startup behavior.
It needs to become the stable trust foundation for the rest of the app.

Done looks like:

- unlock and relock loops are trustworthy
- per-user PIN lifecycle is clear
- device trust reasons are readable
- failed access and recovery events are auditable

### 3. Dashboard Calmness And Session Layer

Goal:
Keep the dashboard useful as more modules become real.

Focus:

- hierarchy tightening
- card consistency
- session/access visibility
- Top 3 and quick capture rhythm
- module snapshot restraint

Why here:
As more modules mature, the dashboard can become noisy unless it is intentionally protected.

Done looks like:

- the home screen stays calm
- session state is visible but quiet
- quick actions feel deliberate
- module cards follow one visual system

### 4. Company Command Centre Safe Operations

Goal:
Turn the company module from a strong read-only surface into a safe operating module.

Focus:

- compliance workflow polish
- website and LinkedIn tracker maturity
- evidence library trust
- safe write mode
- backup-first write-back
- audit summary and export

Why here:
The module already carries real founder/admin value and is ready for careful write-back design.

Done looks like:

- read-only mode stays safe by default
- write mode is explicit and auditable
- source links remain visible
- founder ops feel actionable without becoming chaotic

### 5. Omega Knowledge Engine Completion

Goal:
Make the Knowledge Engine a dependable repo intelligence layer for New Earth projects.

Focus:

- repository validation
- scan status and health
- output previews
- learning notes quality
- architecture map surfacing
- comment suggestion review flow
- project memory
- exports and error handling

Why here:
The shell exists and the value proposition is strong, but it needs operational depth before it becomes a daily tool.

Done looks like:

- repos can be configured safely
- scan health is readable
- outputs are previewable in-app
- failures explain themselves clearly
- the engine teaches, not just lists files

### 6. Asset, QR, And Visual Capture Reliability

Goal:
Strengthen the physical-world operating tools.

Focus:

- print queue reliability
- label history and retries
- connected printer clarity
- capture-to-asset handoff
- evidence and receipt workflow cohesion

Why here:
These tools already solve real problems and become more valuable with reliability and calm reporting.

Done looks like:

- QR printing is predictable
- retries are understandable
- capture output is traceable
- asset evidence paths are easy to trust

### 7. Voice And Intelligence Polish

Goal:
Finish voice cleanup before any broader AI dependence.

Focus:

- startup gate polish
- no-voice fallback clarity
- remembered thread polish
- follow-up and briefing review improvements
- dock state consistency

Why here:
Voice is already present in the product, so it should become dependable before wider intelligence features are layered in.

Done looks like:

- startup choices are clear
- voice capture is predictable
- follow-up feels useful
- the assistant never steals focus from the main workflow

### 8. Backup, Recovery, And Systems Confidence

Goal:
Make the backup/system tools feel like real operational safety tools.

Focus:

- health status clarity
- restore drill visibility
- local reports
- system module cohesion

Why here:
As the app becomes more relied on, recovery confidence matters more.

Done looks like:

- backup state is readable at a glance
- restore readiness is visible
- users know when the system is safe to close

### 9. Repo-Wide Reporting And Export Layer

Goal:
Create a shared reporting pattern across modules that already hold meaningful local data.

Focus:

- printable summaries
- audit exports
- onboarding packs
- founder reports
- module health reports

Why here:
Several modules now have useful local state, but the reporting pattern is fragmented.

Done looks like:

- exports look intentional
- reports are traceable to source data
- module summaries support handoff and review

### 10. External Integrations And Adapter Layer

Goal:
Prepare the app for controlled expansion without breaking local-first principles.

Focus:

- safe adapter contracts
- explicit opt-in settings
- LinkedIn/open-web launcher pattern
- future GitHub/calendar/WordPress hooks
- future AI provider adapter

Why last:
External links are valuable, but they should come after the local operating model is stable.

Done looks like:

- local mode still works without the network
- integrations are optional
- adapters are isolated from core workflows

## Parked Until Later

These should stay parked until the upgrade order above is substantially complete:

- cloud-first sync
- mandatory login
- broad automation that writes without review
- live external dependency on business-critical workflows
- source-code modification by the Knowledge Engine without explicit approval and backup

## Cross-Module Dependencies

Some upgrades should not be started without their dependency layer being healthy.

### Dependency A - Users & Devices before broader protected work

Needed by:

- treasury protection
- startup gate trust
- admin route hardening
- future approval-based workflows

### Dependency B - Dashboard clarity before adding more module snapshots

Needed by:

- company dashboard summaries
- knowledge engine snapshots
- systems/backup visibility
- future report tiles

### Dependency C - Reporting pattern before broad export growth

Needed by:

- users/devices printable packs
- company audit summary
- knowledge-engine report exports
- treasury printable summaries

## Release Gates For Any Major Upgrade

A major upgrade stream should not be treated as complete until:

1. `flutter analyze` passes
2. `flutter test` passes
3. `flutter build windows` passes when runtime code changed
4. manual route checks pass
5. locked-state and unlocked-state behavior are both verified when relevant
6. documentation is updated
7. the change is committed in a clean checkpoint

## Suggested Active Build Sequence

If we continue from the app’s current position, the best active order is:

1. Core Daily Loop Completion
2. Users & Devices Security Hardening
3. Dashboard Calmness And Session Layer
4. Omega Knowledge Engine Completion
5. Company Command Centre Safe Operations
6. Asset, QR, And Visual Capture Reliability
7. Voice And Intelligence Polish
8. Backup, Recovery, And Systems Confidence
9. Repo-Wide Reporting And Export Layer
10. External Integrations And Adapter Layer

## Practical Task Rotation

Use this rule when choosing what to build next:

1. pick one upgrade stream
2. define one small slice in `TASK.md`
3. implement it safely
4. verify analyzer, tests, and build
5. commit it cleanly
6. return to this file and confirm the stream still has the right priority

## Summary

The app is now beyond MVP shell work.
The right next phase is controlled maturation.

That means:

- finish the daily operating loop
- make Users & Devices genuinely trustworthy
- protect the dashboard from noise
- deepen the Knowledge Engine and Company Command Centre carefully
- add reporting and integrations only after the local operating model is solid
