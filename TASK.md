# TASK - Business Foundation

## Goal

Build the first real Business flow so opportunities, funding leads, and practical money actions can be tracked locally and linked to projects where useful.

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
2. Add a local `BusinessRepository` for loading and creating business items.
3. Build a first real `BusinessScreen` backed by local data instead of placeholder content.
4. Build a first add/create business screen.
5. Support the core MVP-safe fields for this slice:
   - opportunity name
   - related project
   - type
   - status
   - company or contact
   - deadline
   - next step
   - follow-up date
   - related document link
   - notes
6. Add business routes and navigation from `More`.
7. Add focused repository and widget coverage for create and list flows.
8. Keep edit, archived views, reminders, conversion flows, and dashboard summaries out of scope for this slice.

## Expected Result

The user should be able to open Business from `More`, see locally stored business items, add a new opportunity or practical action, optionally link it to a project, and have it persist locally.

This should create the first real business-tracking flow for the MVP.
