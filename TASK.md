# TASK - Dashboard Calm Session Layer

## Status

Ready to start.

Users & Devices has now gone through a stronger trust hardening and release-verification pass.
The next best slice is to make the main dashboard feel calmer, clearer, and more intentional around session and access state.

This slice should not add more dashboard noise.
It should make the existing home experience easier to trust at a glance.

## Goal

Tighten the dashboard home hierarchy and session/access presentation so the app opens with clearer orientation, quieter module entry points, and a more dependable trust signal.

This slice sits inside the wider upgrade streams:

- `Dashboard Calm Session Layer`
- `Foundation Hardening`

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/07_non_functional_requirements.md`
- `docs/fsd/08_technical_architecture.md`
- `docs/fsd/10_testing_release.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/roadmap/dashboard_future_roadmap.md`
- `docs/roadmap/major_upgrade_review.md`

Pay special attention to:

- dashboard clarity and hierarchy guidance
- calm UX and non-overwhelm rules
- session and access visibility expectations
- release-readiness and verification discipline

## Requirements

1. Keep the dashboard local-first and offline-first.
2. Keep the home screen calm and focused on the next useful action.
3. Keep session and access state visible without turning the dashboard into a security console.
4. Preserve the Today hero and Top 3 rhythm as the main orientation surface.
5. Keep quick actions and module entry points readable and visually consistent.
6. Do not make the dashboard more crowded just to surface more status.
7. Keep wording calm, practical, and low-pressure.
8. Do not break existing navigation, session lock, or module launch flows.
9. Keep implementation small, reviewable, and testable.
10. If runtime behavior changes, verify analyzer, tests, and Windows build flow honestly.

## First Slice Scope

This slice should focus on the most useful minimum:

1. tighten dashboard hierarchy and spacing where session/access elements appear
2. make the session box/pill feel intentional and consistent
3. keep access shortcuts easy to reach but visually quiet
4. align dashboard module entry actions with the calmer card style
5. preserve fast orientation on app open

Recommended first focus:

- dashboard session visibility consistency
- hero and quick-action hierarchy restraint
- calmer module snapshot actions

## Out of Scope

Do not add these in this slice unless they are already trivial once the core work is done:

- broad dashboard personalization
- new analytics surfaces
- live cloud or account state
- AI dashboard overlays
- new integrations
- heavy module redesigns outside the home screen

## Expected Result

After this slice:

1. the dashboard remains calm even with session/access state visible
2. the session surface feels trustworthy and consistent
3. the user can understand the next useful action quickly
4. module entry actions feel visually aligned
5. the home screen better supports the secured startup flow

## Definition of Done

This slice is only done when:

1. dashboard hierarchy changes are implemented cleanly
2. session/access presentation feels consistent across the home screen
3. related navigation still behaves correctly
4. focused tests are added or updated where practical
5. `flutter analyze` passes
6. `flutter test` passes
7. `flutter build windows` passes if runtime code changed
