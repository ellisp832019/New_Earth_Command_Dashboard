# TASK - Tomorrow Focus and Carry Forward Notes

## Goal

Let the user capture `Carry Forward` notes and `Tomorrow's Focus` from the Planner so the daily loop can start extending beyond the current day.

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

1. Keep loading today's local `DailyPlan`.
2. Add local save support for `carryForwardNotes`.
3. Add local save support for `tomorrowFocus`.
4. Let the user save `Carry Forward` notes from the Planner.
5. Let the user save `Tomorrow's Focus` from the Planner.
6. Keep the Planner copy calm and aligned with the FSD wording.
7. Persist both values locally and reload them after refresh.
8. Add focused repository and widget coverage for both fields.
9. Keep full evening review fields out of scope for this slice.
10. Keep dashboard review navigation polish out of scope for this slice.

## Expected Result

The Planner should let the user record what needs carrying forward and what tomorrow's likely focus is.

Both values should save locally, reload correctly, and support the next slice of the evening review flow.
