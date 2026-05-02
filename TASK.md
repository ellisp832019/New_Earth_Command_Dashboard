# TASK - Evening Review Fields and Save Flow

## Goal

Let the user complete the first real `Evening Review` in the Planner and save it locally as part of today's `DailyPlan`.

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
2. Add local save support for the first evening review fields:
   - `whatMovedForward`
   - `whatWasCompleted`
   - `whatWasLearned`
   - `blockers`
3. Let the user edit and save those fields from the Planner.
4. Keep the Planner copy calm and aligned with the FSD review wording.
5. Persist the review locally and reload it after refresh.
6. Update the stored `eveningReview` summary field when saving the review.
7. Add focused repository and widget coverage for the evening review save flow.
8. Keep dashboard review navigation polish out of scope for this slice.
9. Keep automatic carry-forward task movement out of scope for this slice.

## Expected Result

The Planner should let the user record what moved forward, what was completed, what was learned, and what blocked progress today.

The evening review should save locally, reload correctly, and prepare the app for the next dashboard review-entry slice.
