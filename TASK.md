# TASK - Settings Foundation

## Goal

Build the first real Settings flow so core local app preferences can be viewed and adjusted safely.

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

1. Keep the current dashboard, projects, tasks, planner, journal, learning, content, business, wellbeing, inbox, and dashboard quick capture flows working.
2. Add a local `SettingsRepository` or reuse the existing app settings data source cleanly.
3. Build a first real `SettingsScreen` backed by local data instead of placeholder content.
4. Expose the current MVP-safe settings already present in local storage where practical.
5. Support the core MVP-safe fields for this slice:
   - top 3 task limit view
   - dashboard card visibility toggles that already exist in settings storage where practical
   - app version display if already available
6. Add focused widget and repository coverage for settings load/save where practical.
7. Keep theme switching, destructive reset flows, and advanced configuration out of scope for this slice.

## Expected Result

The user should be able to open Settings, see real locally stored settings information, adjust safe MVP settings, and have those choices persist locally.

This should create the first real configuration surface for the MVP.
