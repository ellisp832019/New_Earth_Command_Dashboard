# TASK - Tasks Screen Reads Local Tasks

## Goal

Show the local task list on the Tasks screen.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/08_technical_architecture.md`

## Requirements

1. Add local task loading for the Tasks screen.
2. Read tasks from the local database.
3. Show tasks with title, status, priority, and linked project name when available.
4. Add focused tests for task loading.
5. Keep the screen read-only for now.
6. Do not add task creation or editing yet.

## Expected Result

The Tasks screen should show local tasks from dashboard data.

If no tasks are available, the screen should show a clear empty state.
