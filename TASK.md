# TASK - Inbox Processing Foundation

## Status

Ready to start.

The app already supports Quick Capture into Inbox and has the broader local daily loop in place.
This slice finishes the next missing part of that loop:
turning Inbox into a calm processing space instead of only a holding area.

## Goal

Build the first practical Inbox processing flow so captured items can be reviewed, converted, and parked without breaking the app's calm daily rhythm.

This slice sits inside the wider upgrade stream:

- `Core Daily Loop Completion`

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/07_non_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/10_testing_release.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/roadmap/mvp_execution_plan.md`

Pay special attention to:

- `FR-INBOX-001` to `FR-INBOX-006`
- `FR-PLAN-005` and `FR-PLAN-006`
- `NFR-USE-003`
- `NFR-USE-005`
- `NFR-EMO-001`
- `NFR-EMO-004`

## Requirements

1. Keep the Inbox local-first and offline-first.
2. Preserve the calm capture-first model:
   captures should stay quick, processing should happen later.
3. Allow the user to clearly review unprocessed Inbox items.
4. Add the first safe conversion flow from Inbox into real records.
5. Prefer the simplest useful conversions first instead of building every path at once.
6. Add a clear parked/later state where appropriate instead of forcing immediate processing.
7. Keep wording gentle and non-overwhelming.
8. Do not make the Dashboard noisier just to support Inbox processing.
9. Keep repository, controller, and UI responsibilities separated cleanly.
10. Do not break existing Quick Capture flows.

## First Slice Scope

This slice should focus on the most useful minimum:

1. Show unprocessed Inbox items clearly.
2. Let the user open one Inbox item and choose a next action.
3. Support at least one real conversion path cleanly.
4. Support parking an Inbox item for later.
5. Persist the processing result correctly after app restart.

Recommended first conversion targets:

- Inbox item -> Task
- Inbox item -> Journal Entry

If only one conversion path is practical in the first pass, choose:

- Inbox item -> Task

## Out of Scope

Do not add these in this slice unless they are already trivial once the core flow works:

- bulk Inbox processing
- advanced automation
- AI triage
- cloud sync
- broad export features
- external integrations
- complicated multi-step wizards

## Expected Result

After this slice:

1. Quick Capture can still save into Inbox safely.
2. The Inbox screen feels like a real review surface.
3. The user can process at least one Inbox item into a useful destination.
4. The user can park an Inbox item without deleting it.
5. Data still persists cleanly after closing and reopening the app.

## Definition of Done

This slice is only done when:

1. Inbox processing UI exists.
2. Processing state saves locally.
3. Converted items are created correctly.
4. Parked items behave clearly and remain recoverable.
5. Related screens refresh correctly after conversion.
6. Focused tests are added or updated.
7. `flutter analyze` passes.
8. `flutter test` passes.
9. `flutter build windows` passes if runtime code changed.
