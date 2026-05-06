# MVP Execution Plan

This document is the working build plan for the New Earth Command Dashboard MVP.

It is derived from:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/09_mvp_roadmap.md`
- `docs/fsd/10_testing_release.md`

## How We Work

We move in one active slice at a time.

Rules:

1. `TASK.md` always describes the current slice only.
2. When a slice is finished and verified, `TASK.md` is rewritten to the next slice.
3. This plan stays broader than `TASK.md` and tracks the route to a usable V0.1.
4. We finish the core daily loop before widening the app into every supporting module.

## Current Build Position

Completed foundation:

- App shell
- Material 3 theme
- Bottom navigation
- More screen links
- Drift and SQLite setup
- Core MVP tables
- Seeded default projects and app settings
- Automatic blank DailyPlan creation for today
- Dashboard reading local data
- Projects list reading seeded data
- Tasks list reading local data
- Planner reading today's DailyPlan
- Top 3 selection from Planner and Tasks
- Dashboard Top 3 actions
- Dashboard quick-edit focus flow
- Focus reason and clear focus flow
- Project create/edit/archive flows
- Task create/edit/status/filter/search/archive flows
- Journal, Learning, Content, Business, Wellbeing, Inbox, and Settings foundations
- Dashboard Quick Capture saving to Inbox
- Voice Capture saving reviewed transcripts into local Tasks, Journal, Inbox, Content, and Business data
- Business opportunity type/status labels aligned with the FSD
- Live press-to-listen microphone capture in the Voice Assistant

Still parked on purpose:

- Voice assistant expansion
- Always-listening voice mode
- External integrations
- AI features
- Cloud sync

## Core MVP Route

We should stick to this route until the app supports a real daily loop:

1. Run a V0.1 release-readiness pass
2. Tighten manual persistence testing
3. Align stale docs with the current app
4. Add Inbox processing only after the current local capture loop is stable

## Immediate Slice Queue

These are the next slices to tackle in order unless a blocker appears:

1. `V0.1 Manual Release Pass`
2. `Inbox Processing Foundation`
3. `Project Detail Linked Module Surfacing`

## Why This Order

This order follows the FSD priority and gets the system usable as fast as possible:

- The core local capture loop is now present, so the next work should harden what exists.
- Voice Capture gives quick entry without adding cloud transcription or automation risk.
- Business status alignment keeps the app consistent with the FSD before broader release testing.
- Inbox processing is useful, but should come after capture, tasks, and review paths are stable.

## Remaining Core MVP Milestones

### 1. Daily Loop Completion

- Save `carryForwardNotes`
- Save `tomorrowFocus`
- Save evening review fields
- Add a reliable dashboard path into the review section
- Verify planner persistence after restart

### 2. Project Management Completion

- Project detail screen
- Add project flow
- Edit project flow
- Manual progress updates
- Archive project flow

### 3. Task Management Completion

- Add task flow
- Edit task flow
- Move to Today
- Park task from UI
- Mark done from Tasks
- Filter by status
- Filter by project

### 4. Journal Completion

- Journal list
- Journal entry form
- Project link
- Task link
- Edit flow

### 5. Capture Completion

- Quick Capture dialog
- Inbox save
- Inbox view
- Convert inbox item later

## V0.1 Release Gate

We should treat V0.1 as ready only when this real workflow works without confusion or data loss:

1. Open app
2. See Dashboard
3. Set focus
4. Create or choose tasks
5. Select Top 3
6. Work from Dashboard / Tasks / Projects
7. Record evening review
8. Set tomorrow focus
9. Add a journal entry
10. Close and reopen app
11. Confirm everything is still there

## Slice Definition of Done

A slice is only complete when:

- UI exists
- Data saves locally
- Data loads again
- Related screens refresh correctly
- Focused tests exist or were updated
- `flutter test` passes
- `flutter analyze` passes
- `flutter build windows` passes when the slice affects the running app

## Task Rotation Rule

When a slice is complete:

1. Verify the slice
2. Update this plan if priorities changed
3. Rewrite `TASK.md` for the next slice
4. Commit in a clean checkpoint when asked or when a milestone closes
