# TASK - Tasks Module Foundation

## Goal

Build the core task tracking system to allow users to create, manage, and track tasks linked to projects.

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

1. Keep existing functionality working (dashboard, projects, business).
2. Create Task model and database table.
3. Implement TaskRepository with CRUD operations.
4. Build Tasks screen with task cards showing title, status, project link.
5. Create add/edit task form with fields: title, description, project selection, status, priority, due date.
6. Support task status updates (todo, in progress, done, parked).
7. Allow filtering tasks by status and project.
8. Add basic widget tests for task creation and editing.
9. Keep advanced features (top 3 selection, daily planning) out of scope for this slice.

## Expected Result

Users can view all tasks, create new tasks linked to projects, edit existing tasks, update status, and filter by project/status. The task system integrates with the existing project system.
