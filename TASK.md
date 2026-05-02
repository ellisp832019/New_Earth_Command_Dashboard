# TASK - Project Detail and Add/Edit Project Foundation

## Goal

Let the user open a project, create a project, and edit a project using calm local-first flows that match the existing Projects screen.

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

1. Keep loading the seeded local project list.
2. Add local repository support to:
   - load one project by id
   - load a simple project detail snapshot
   - create a project
   - update a project
3. Build a `Project Detail` screen and route.
4. Build a shared `Add / Edit Project` screen and route.
5. Let the user create a project with at least:
   - name
   - short description
   - vision
   - status
   - priority
   - progress percentage
   - current milestone
   - next action
   - notes
6. Let the user edit the same fields for an existing project.
7. Let the user open project detail from the Projects list.
8. Show related task sections on the detail screen using currently available local task data.
9. Add focused repository and widget coverage for detail, create, and edit flows.
10. Keep archive flow, task creation from project detail, and date pickers out of scope for this slice.

## Expected Result

The app should let the user move from the Projects list into a real project detail screen, and create or edit project records locally.

Project changes should save locally, reload correctly, and prepare the next slice for archive and deeper project-linked workflows.
