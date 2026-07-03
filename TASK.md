# TASK - Users & Devices Route Protection Sweep

## Status

Ready to start.

The Knowledge Engine work is clean.
The next active stream in the repo-wide execution plan is Users & Devices trust completion, starting with the route protection sweep.

## Goal

Make the Security Lock the only public entry point while the app is locked and remove direct bypasses into protected Users & Devices admin surfaces.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/03_user_roles_navigation.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/10_testing_release.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/roadmap/users_devices_upgrade_roadmap.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/USER_GUIDE.md`

Pay special attention to:

- locked-state entry behaviour
- protected routes and resume routing
- helper buttons that must stay honest
- restore/unlock flow after a valid local unlock

## Requirements

1. Keep the app local-first and offline-first.
2. Keep the lock screen the only public entry point while locked.
3. Keep unlock resume routing predictable.
4. Keep wording calm and clear.
5. Keep the slice small, reviewable, and testable.
6. Update documentation only where route flow really changed.
7. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. make locked-state route protection central and consistent
2. prevent direct navigation into protected Users & Devices surfaces while locked
3. keep the intended destination available after a valid unlock
4. keep lock-screen helper buttons honest about what is blocked

## Out of Scope

Do not add these in this slice unless they are already trivial once the route sweep is done:

- failed unlock lockout redesign
- recovery and admin reset workflows
- onboarding tightening
- device quarantine improvements
- broader security redesign

## Expected Result

After this slice:

1. locked users stay on Security Lock until they unlock locally
2. protected admin routes do not open through a bypass
3. resumed routes still feel smooth after unlock
4. the trust spine feels more consistent

## Definition of Done

This slice is only done when:

1. the relevant Users & Devices tests still pass
2. any touched runtime flow is checked against the module docs
3. wording and runtime flow still match where updated
4. `flutter analyze` passes
5. focused `flutter test` passes
6. `flutter build windows` passes if runtime code changed
