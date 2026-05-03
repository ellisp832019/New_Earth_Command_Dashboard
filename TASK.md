# TASK - Project Journal Surfacing

## Goal

Show linked journal history on Project Detail so project pages start to feel like real build homes, not just metadata cards.

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

1. Keep the current project detail, journal list, and journal create/edit flows working.
2. Extend the project detail repository snapshot so it loads recent linked journal entries, not just a count.
3. Show a calm read-only journal section on Project Detail with:
   - date
   - title
   - category
   - short preview
4. Keep the existing journal count signal if it still helps, but do not duplicate the exact same information noisily.
5. Make journal items in Project Detail open the existing journal edit screen.
6. Add focused repository and widget coverage for linked journal surfacing.
7. Keep project-linked learning/content detail lists, project activity timelines, and cross-module conversions out of scope for this slice.

## Expected Result

The user should be able to open a project and immediately see its recent linked journal history, then open one of those entries for fuller editing if needed.

This should make Project Detail feel more like the real build record for each New Earth project.
