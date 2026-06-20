# TASK - Dashboard Home Hierarchy

## Status

In progress. The current slice is tightening the Dashboard home hierarchy so the screen reads as a calm command centre with clear primary and secondary layers.

For the broader plan, see [`docs/roadmap/dashboard_future_roadmap.md`](docs/roadmap/dashboard_future_roadmap.md).

## Goal

Make the Dashboard easier to scan and use by keeping the home hero, Top 3 tasks, active projects, quick capture, and session/access state in a clear order, while pushing supporting modules into a calmer secondary tier.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/06_functional_requirements.md`
- `docs/fsd/07_non_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/09_mvp_roadmap.md`
- `docs/roadmap/app_roadmap.md`
- `docs/roadmap/dashboard_future_roadmap.md`

## Requirements

1. Keep the Dashboard local-first and offline-first.
2. Keep the home hero as the first clear read on the screen.
3. Keep Top 3 tasks as the main action surface.
4. Keep active projects visible but secondary to today’s focus.
5. Keep quick capture available without stealing attention.
6. Keep the session and access strip visible, intentional, and calm.
7. Separate primary work surfaces from supporting tools with clear section hierarchy.
8. Reduce visual noise in the lower dashboard sections.
9. Keep the dashboard cards aligned to one design language.
10. Preserve all existing dashboard functionality while improving hierarchy.
11. Run `flutter analyze` after the changes if possible.

## Expected Result

The Dashboard feels calmer and more structured. The user can open the app, see today’s focus and Top 3 work immediately, understand what matters next, and only then move into supporting modules or secondary tools.
