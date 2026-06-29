# TASK - Dashboard Daily Flow Tools

## Status

Ready to start.

The Dashboard Calm Session Layer has now completed its first three slices:

- session visibility consistency
- card hierarchy restraint
- module snapshot calmness rules

The next best dashboard slice is to strengthen the daily operating loop without making the home screen louder.

## Goal

Tighten the dashboard's day-to-day working rhythm so `Today Focus`, `Top 3`, `Active Projects`, and `Quick Capture` feel more connected, more useful, and easier to trust at a glance.

This slice sits inside the wider upgrade streams:

- `Dashboard Calm Session Layer`
- `Core Daily Loop Completion`
- `Foundation Hardening`

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/07_non_functional_requirements.md`
- `docs/fsd/10_testing_release.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/roadmap/dashboard_future_roadmap.md`
- `docs/roadmap/major_upgrade_review.md`
- `docs/roadmap/dashboard_daily_flow_tools_next_slice.md`

Pay special attention to:

- calm dashboard hierarchy
- daily planning and handoff flow
- low-friction capture expectations
- persistence and release verification discipline

## Requirements

1. Keep the dashboard local-first and offline-first.
2. Keep the Today hero as the main orientation surface.
3. Strengthen the relationship between Today Focus, Top 3, Active Projects, and Quick Capture.
4. Improve clarity without adding new dashboard noise.
5. Keep wording calm, practical, and low-pressure.
6. Preserve existing navigation, planner handoff, and quick capture behaviour unless the slice is explicitly improving them.
7. Keep changes small, reviewable, and testable.
8. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. clarify how Today Focus hands into the Top 3 loop
2. make Active Projects feel like contextual support rather than a competing panel
3. keep Quick Capture fast, obvious, and secondary to committed work
4. improve carry-forward and tomorrow-focus cues where already present
5. preserve calm spacing and readable action groups

Recommended first focus:

- daily flow hierarchy
- Top 3 / project / capture handoff language
- subtle context cues rather than new metrics

## Out of Scope

Do not add these in this slice unless they are already trivial once the core work is done:

- new analytics surfaces
- broad personalization controls
- heavy module redesigns
- cloud or account-linked workflow
- AI overlays on the dashboard

## Expected Result

After this slice:

1. the dashboard better explains what to do now and what can wait
2. Today Focus and Top 3 feel more connected
3. Active Projects supports the daily plan without pulling attention away
4. Quick Capture stays available without becoming the primary action surface
5. the home screen stays calm while becoming more operationally useful

## Definition of Done

This slice is only done when:

1. the daily flow hierarchy changes are implemented cleanly
2. the Today / Top 3 / Projects / Capture loop feels more intentional
3. related navigation still behaves correctly
4. focused tests are added or updated where practical
5. `flutter analyze` passes
6. `flutter test` passes
7. `flutter build windows` passes if runtime code changed
