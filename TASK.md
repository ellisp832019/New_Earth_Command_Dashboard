# TASK - Business Edit Foundation

## Goal

Build the first real edit flow for Business so saved opportunities can be reopened and refined locally.

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

1. Keep the current dashboard, projects, tasks, planner, journal, learning, content, business, wellbeing, inbox, quick capture, and settings flows working.
2. Add the first safe edit path for an existing Business item.
3. Allow a Business list item to open an edit screen.
4. Reuse the existing add-business form cleanly if practical instead of creating a second form pattern.
5. Support updating the current MVP-safe Business fields already present in local storage.
6. Persist updates locally and refresh the Business list after save.
7. Add focused widget and repository coverage for reopening and editing a Business item.
8. Keep archive, delete, conversion, and advanced automation out of scope for this slice.

## Expected Result

The user should be able to open a saved Business item, edit its current fields safely, save it locally, and see the updated version reflected in the live Business list.
