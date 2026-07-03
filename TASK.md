# TASK - Users & Devices Failed Unlock and Lockout Confidence

## Status

Ready to start.

The route protection sweep is complete.
The next useful slice is to make repeated bad PIN attempts and lockout cooldowns read more clearly in the Users & Devices flow.

## Goal

Make the failed-unlock and lockout flow easier to understand so operators can see:

- when a wrong PIN is just a normal mismatch
- when a cooldown is active
- when a lockout has just been triggered
- what the next safe action is

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/roadmap/users_devices_upgrade_roadmap.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/USER_GUIDE.md`

Pay special attention to:

- which slices are complete
- which slice comes next in the active stream
- how the review docs describe the current maturity level

## Requirements

1. Keep the wording calm, concise, and practical.
2. Keep the slice small, reviewable, and testable.
3. Make the lockout state easy to distinguish from a plain failed PIN attempt.
4. Keep the audit and recovery guidance readable.
5. Verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. make the lockout and cooldown wording clearer in the PIN registry service
2. keep the PIN registry screen copy aligned with the real flow
3. update the focused lockout tests to match the clearer behavior

## Out of Scope

Do not add these in this slice unless they are already trivial while updating the docs:

- new security features
- broad roadmap rewriting
- visual redesign

## Expected Result

After this slice:

1. failed unlock and lockout states are easier to distinguish
2. the next safe admin step is obvious from the screen copy
3. the focused tests cover the clearer behavior

## Definition of Done

This slice is only done when:

1. the lockout copy reads cleanly
2. the focused tests pass
3. `flutter analyze` passes
4. `flutter build windows` passes
