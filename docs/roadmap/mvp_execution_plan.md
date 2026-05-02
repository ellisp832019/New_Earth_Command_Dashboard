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

Still parked on purpose:

- Voice assistant expansion
- External integrations
- AI features
- Cloud sync

## Core MVP Route

We should stick to this route until the app supports a real daily loop:

1. Finish the Daily Planner loop
2. Finish core Project CRUD
3. Finish core Task CRUD
4. Add Journal foundation
5. Add Quick Capture and Inbox
6. Add the supporting modules in light MVP form
7. Run persistence, manual workflow, and polish passes

## Immediate Slice Queue

These are the next slices to tackle in order unless a blocker appears:

1. `Tomorrow Focus + Carry Forward Notes`
2. `Evening Review Fields`
3. `Dashboard Start Evening Review Action`
4. `Project Detail Screen Foundation`
5. `Add / Edit Project Screen`
6. `Task Add / Edit Screen`
7. `Task Filters: Status and Project`
8. `Journal List Foundation`
9. `Journal Entry Form Foundation`
10. `Quick Capture Placeholder to Real Inbox Save`

## Why This Order

This order follows the FSD priority and gets the system usable as fast as possible:

- The planner loop is already close, so finishing it gives a complete morning-to-evening flow.
- Projects and Tasks still need creation and editing, which are core MVP requirements.
- Journal is part of the V0.1 core loop and should land before the wider support modules.
- Quick Capture matters for real usage, but only after the core loop can hold the captured work.

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
