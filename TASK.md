# TASK - Planner Edits Morning Intention and Main Focus

## Goal

Let the user edit and save today's Morning Intention and Main Focus from the Planner screen.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/10_testing_release.md`

## Requirements

1. Keep loading today's DailyPlan from the local database.
2. Add local save support for `Morning Intention`.
3. Add local save support for `Main Focus`.
4. Refresh planner data after save.
5. Make sure saved `Main Focus` appears on the Dashboard.
6. Add focused repository and widget tests.
7. Keep all other planner sections read-only for now.

## Expected Result

The Planner screen should let the user write and save `Morning Intention` and `Main Focus`.

Saved values should persist locally and show up again after navigation or restart.
