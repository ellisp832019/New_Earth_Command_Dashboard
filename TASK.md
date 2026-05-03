# TASK - Wellbeing Foundation

## Goal

Build the first real Wellbeing flow so energy, mood, stress, and sustainable pacing can be tracked locally as part of the daily build rhythm.

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

1. Keep the current dashboard, projects, tasks, planner, journal, learning, content, and business flows working.
2. Add a local `WellbeingRepository` for loading and creating wellbeing check-ins.
3. Build a first real `WellbeingScreen` backed by local data instead of placeholder content.
4. Build a first add/create wellbeing check-in screen.
5. Support the core MVP-safe fields for this slice:
   - date
   - energy
   - mood
   - stress
   - sleep quality
   - notes
   - movement done
   - food and water ok
   - meditation or reflection done
   - suggested workload
6. Add wellbeing routes and navigation from `More`.
7. Add focused repository and widget coverage for create and list flows.
8. Keep edit, trends, dashboard wellbeing summaries, and recommendation logic out of scope for this slice.

## Expected Result

The user should be able to open Wellbeing from `More`, see locally stored wellbeing check-ins, add a new daily check-in, and have it persist locally.

This should create the first real sustainability-tracking flow for the MVP.
