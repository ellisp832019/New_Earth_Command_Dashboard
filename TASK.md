# TASK - Content Foundation

## Goal

Build the first real Content flow so New Earth communication ideas can be tracked locally and linked to projects.

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

1. Keep the current dashboard, projects, tasks, planner, journal, and learning flows working.
2. Add a local `ContentRepository` for loading and creating content items.
3. Build a first real `ContentScreen` backed by local data instead of placeholder content.
4. Build a first add/create content screen.
5. Support the core MVP-safe fields for this slice:
   - title
   - related project
   - platform
   - content type
   - status
   - draft text
   - image needed
   - image prompt
   - notes
6. Add content routes and navigation from `More`.
7. Add focused repository and widget coverage for create and list flows.
8. Keep edit, publish-date scheduling, published-link flow, journal linking, and dashboard summaries out of scope for this slice.

## Expected Result

The user should be able to open Content from `More`, see locally stored content items, add a new idea or draft, optionally link it to a project, and have it persist locally.

This should create the first real communication-tracking flow for the MVP.
