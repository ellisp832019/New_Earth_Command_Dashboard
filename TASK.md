# TASK - Task Add/Edit Screen Foundation

## Goal

Let the user create and edit tasks through calm local-first flows that connect cleanly to the existing Tasks and Projects areas.

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

1. Keep loading the local task list from Drift.
2. Add local repository support to:
   - load one task by id
   - create a task
   - update a task
3. Build a shared `Add / Edit Task` screen and route.
4. Let the user create a task from the Tasks screen.
5. Let the user edit an existing task from the Tasks list.
6. Let the task form support at least:
   - title
   - description
   - project
   - category
   - priority
   - status
   - energy level
   - estimated minutes
   - notes
7. Allow opening the task form from a Project Detail flow with the project preselected.
8. Use calm defaults:
   - default status `Inbox`
   - default priority `Medium`
9. Add focused repository and widget coverage for create, edit, and project-linked task creation.
10. Keep task delete, archive, due date picker UI, filters, and sort controls out of scope for this slice.

## Expected Result

The app should let the user create and edit task records locally, with optional project linking, and see those changes reload correctly in the Tasks view.

This should prepare the next slice for task filters, task detail polish, and deeper project-to-task workflows.
