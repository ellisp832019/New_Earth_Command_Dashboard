# TASK - Inbox Foundation

## Goal

Build the first real Inbox flow so quick captured items can be stored locally before being sorted into the wider New Earth system.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/09_mvp_roadmap.md`
- `docs/fsd/10_testing_release.md`

## Requirements

1. Keep the current dashboard, projects, tasks, planner, journal, learning, content, business, and wellbeing flows working.
2. Add a local `InboxRepository` for loading and creating inbox items.
3. Build a first real `InboxScreen` backed by local data instead of placeholder content.
4. Build a first add/create inbox item screen.
5. Support the core MVP-safe fields for this slice:
   - title
   - body
   - type
   - related project
   - status
6. Add inbox routes and navigation from `More`.
7. Add focused repository and widget coverage for create and list flows.
8. Keep edit, convert flows, archive flows, and dashboard quick-capture entry points out of scope for this slice.

## Expected Result

The user should be able to open Inbox from `More`, see locally stored inbox items, add a new captured item, and have it persist locally.

This should create the first real quick-capture holding flow for the MVP.
