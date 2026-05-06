# TASK - Project Detail Linked Module Surfacing

## Goal

Make Project Detail feel like the home for a project by surfacing linked Journal, Learning, Content, and Business records, while keeping quick-create actions project-aware.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/10_testing_release.md`

## Requirements

1. Keep projects, tasks, planner, voice, and inbox flows working.
2. Show active and blocked tasks as before.
3. Surface recent linked Journal entries, Learning items, Content ideas, and Business opportunities on Project Detail.
4. Add project-aware create shortcuts for Journal, Learning, Content, and Business from Project Detail.
5. Keep the layout calm and readable.
6. Preserve project detail archive/edit/task flows.
7. Run `flutter analyze`, `flutter test`, and a Windows build if possible.

## Expected Result

The user can open a project and quickly see the related work trail, then jump straight into adding the next linked item without hunting through the app.
