# TASK - Major Upgrade Review Alignment

## Status

Ready to start.

The route protection sweep is complete.
The next useful slice is to align the repo-wide major-upgrade docs with that progress so the execution plan and review notes stay honest about what is already done and what comes next.

## Goal

Update the major-upgrade docs so they clearly reflect:

- the completed Users & Devices route protection sweep
- the next Users & Devices hardening slice
- the current repo-wide upgrade position

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/roadmap/major_upgrade_review.md`
- `docs/roadmap/users_devices_upgrade_roadmap.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/USER_GUIDE.md`

Pay special attention to:

- which slices are complete
- which slice comes next in the active stream
- how the review docs describe the current maturity level

## Requirements

1. Keep the repo docs truthful and current.
2. Keep wording calm, concise, and practical.
3. Keep the slice small, reviewable, and testable.
4. Update only the documentation that actually needs the maturity or sequencing update.
5. If any runtime code changes happen as part of the doc alignment, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. mark the route protection sweep as completed in the execution plan
2. make the next Users & Devices hardening slice explicit
3. keep the major-upgrade review aligned with the current repo position

## Out of Scope

Do not add these in this slice unless they are already trivial while updating the docs:

- runtime feature changes
- new module work
- broad roadmap rewriting
- visual redesign

## Expected Result

After this slice:

1. the major-upgrade docs match the work that has already landed
2. the next trust-hardening step is easier to see
3. the repo-wide maturity read stays current

## Definition of Done

This slice is only done when:

1. the docs read cleanly after the update
2. the sequence of active work is still easy to follow
3. `flutter analyze` passes if runtime files changed
4. focused tests pass if runtime files changed
5. `flutter build windows` passes if runtime files changed
