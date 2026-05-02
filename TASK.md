# TASK - Task Repository Foundation

## Goal

Add the first task data operations and protect the Top 3 task rule.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/08_technical_architecture.md`

## Requirements

1. Add a TaskRepository for creating tasks and reading active tasks.
2. Add repository actions for marking a task Done and moving a task to Parked.
3. Add a task selection service that enforces the Top 3 task limit.
4. Keep Top 3 selection limited to three tasks.
5. Add focused tests for task creation, status changes, and Top 3 enforcement.
6. Do not wire the Tasks screen or Dashboard to live data yet.

## Expected Result

The database should support creating, listing, completing, parking, and selecting tasks.

The Top 3 task rule should prevent selecting a fourth active top task.
