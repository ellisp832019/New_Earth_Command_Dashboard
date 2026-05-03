# TASK - Journal Edit Foundation

## Goal

Let the user reopen and update existing journal entries so the build history can stay accurate as thoughts settle.

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

1. Keep the current journal list and create-entry flow working.
2. Add repository support to load and update an existing journal entry.
3. Extend `AddEditJournalEntryScreen` so it supports both create and edit modes.
4. Make each journal list item open the edit screen.
5. Preserve the current MVP-safe field set:
   - title
   - date
   - related project
   - related task
   - category
   - what I worked on
   - what I learned
   - next actions
6. Add focused repository and widget coverage for editing and reloading saved changes.
7. Keep filters, tags, LinkedIn/website flags, journal-to-content conversion, and create-task-from-entry out of scope for this slice.

## Expected Result

The user should be able to open an existing journal entry, update its details, save it, and see the edited version persist in the Journal list and local database.

This should make the Journal usable as a real living build log instead of a write-once capture flow.
