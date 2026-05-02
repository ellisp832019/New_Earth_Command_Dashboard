# TASK - Journal Foundation

## Goal

Build the first real Journal flow so progress can be captured locally as part of the New Earth daily loop.

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

1. Keep the current dashboard, planner, projects, and tasks flows working.
2. Add a local `JournalRepository` for loading and creating journal entries.
3. Build a first read-only `JournalScreen` backed by local data instead of placeholder content.
4. Build a first `AddEditJournalEntryScreen` for creating a journal entry.
5. Support the core MVP fields only for this slice:
   - title
   - date
   - related project
   - related task
   - category
   - what I worked on
   - what I learned
   - next actions
6. Add journal routes and navigation from `More`.
7. Add focused repository and widget coverage for create and list flows.
8. Keep edit, filters, tags, LinkedIn/website flags, and journal-to-content conversion out of scope for this slice.

## Expected Result

The user should be able to open Journal from `More`, see locally stored entries, add a new journal entry, link it to a project or task if needed, and have it persist locally.

This should create the first real build-history capture flow for the MVP.
