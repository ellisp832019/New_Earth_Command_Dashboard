# TASK - Task Status Actions and Filters Foundation

## Goal

Let the user work the task list more directly by updating task status from the Tasks screen and filtering tasks without leaving the current flow.

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

1. Keep the existing local task create/edit flow working.
2. Add local support for these task status actions:
   - mark done
   - move to today
   - park
3. Make status actions available directly from the Tasks screen.
4. Keep DailyPlan and Top 3 data in sync when a task is marked done or parked.
5. Add a task status filter with at least:
   - All
   - Inbox
   - Today
   - Planned
   - In Progress
   - Blocked
   - Done
   - Parked
6. Add a task project filter with:
   - All Projects
   - seeded and user-created local projects
7. Keep filter UI calm and readable on the existing Tasks screen.
8. Show helpful empty states when filters return no tasks.
9. Add focused repository/controller/widget coverage for status actions and both filter types.
10. Keep search, sort, archive, due date picker UI, and delete flow out of scope for this slice.

## Expected Result

The Tasks screen should let the user move tasks into Today, mark them Done, park them for later, and narrow the list by status or project without losing the calm local-first workflow.

This should prepare the next slice for archive, search, and richer task detail polish.
