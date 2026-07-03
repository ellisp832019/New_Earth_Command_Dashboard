# TASK - Dashboard Daily Flow Tools

## Status

Ready to start.

The calm session layer is in a healthier place now.

The next active slice should make the main daily flow feel tighter so the dashboard answers the next useful step more clearly.

## Goal

Strengthen the dashboard's daily operating loop around:

- Today Focus
- Top 3 Tasks
- Active Projects
- Quick Capture

This slice sits inside:

- `Dashboard Calm Session Layer`
- `Core Daily Loop Completion`
- `Repo Upgrade Program`

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/10_testing_release.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/roadmap/major_upgrade_review.md`
- `docs/roadmap/dashboard_future_roadmap.md`
- `docs/roadmap/dashboard_daily_flow_tools_next_slice.md`

Pay special attention to:

- Today to Top 3 handoff
- Active Projects as support context
- Quick Capture as a safe side lane
- carry-forward and tomorrow-focus cues
- keeping the dashboard calm and readable

## Requirements

1. Keep the app local-first and offline-first.
2. Keep wording calm, practical, and low-pressure.
3. Prefer proof, alignment, and clarity over adding more surface area.
4. Keep the slice small, reviewable, and testable.
5. Update documentation only where the runtime flow truly changed or needs clearer verification wording.
6. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. make the Today panel hand off into Top 3 more explicitly
2. keep Active Projects clearly subordinate to the daily focus
3. keep Quick Capture visibly secondary to committed work
4. make carry-forward and tomorrow-focus cues easier to read

## Out of Scope

Do not add these in this slice unless they are already trivial once the flow work is done:

- new dashboard modules
- heavy analytics
- unrelated security changes
- voice integration changes
- broader module redesign

## Expected Result

After this slice:

1. the dashboard answers the next useful move more clearly
2. Top 3 feels like the real continuation of Today Focus
3. Quick Capture feels like a safe side lane, not the main work surface
4. the daily flow stays calm and easy to trust

## Definition of Done

This slice is only done when:

1. the relevant dashboard widget tests still pass
2. any touched runtime flow is checked against the dashboard flow docs
3. guide wording and dashboard wording still match the real flow where updated
4. `flutter analyze` passes
5. focused `flutter test` passes
6. `flutter build windows` passes if runtime code changed
