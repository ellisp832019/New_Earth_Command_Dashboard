# TASK - Project Archive Foundation

## Goal

Let the user archive projects safely so completed or paused work can leave the active project view without losing its history.

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

1. Keep the current project detail, add/edit, and task-linked project flows working.
2. Add local repository support to archive a project by setting `isArchived = true`.
3. Make archive available from the Project Detail screen.
4. Ask for confirmation before archiving.
5. Remove archived projects from the default active project list and dashboard active project counts.
6. Keep related task data intact when a project is archived.
7. Add focused repository, controller, and widget coverage for the archive flow.
8. Keep restore, delete, archived-project views, and project archive filters out of scope for this slice.

## Expected Result

The user should be able to archive a project safely from Project Detail, confirm the action, and see the archived project leave normal active views while its related history stays intact locally.

This should prepare the next slice for richer project navigation and project-history workflows.
