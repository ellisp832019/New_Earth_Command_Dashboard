# TASK - Users & Devices Release Verification Pass

## Status

Ready to start.

The persistence and migration hardening slice has completed.

The next active slice should finish the release-confidence pass for the local trust layer so the module is easier to verify, explain, and hand over.

## Goal

Make Users & Devices Control feel release-ready from an operator point of view by tightening the final verification path around:

- route trust confidence
- restart and relock predictability
- guide and checklist alignment
- focused test and manual proof discipline

This slice sits inside:

- `Users & Devices Trust Completion`
- `Foundation Hardening`
- `Repo Upgrade Program`

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/10_testing_release.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/fsd/14_repo_upgrade_program.md`
- `docs/roadmap/repo_upgrade_20_task_execution_queue.md`
- `docs/roadmap/users_devices_upgrade_roadmap.md`
- `docs/roadmap/users_devices_manual_test_checklist.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/UPGRADE_PLAN_NEXT_SLICE.md`

Pay special attention to:

- locked-route behaviour
- resume-after-unlock behaviour
- PIN recovery and lockout proof
- restart and relock confidence
- access review drill-down accuracy
- guide wording that should match the real screens exactly

## Requirements

1. Keep the app local-first and offline-first.
2. Keep wording calm, practical, and low-pressure.
3. Prefer proof, alignment, and clarity over adding more surface area.
4. Keep the slice small, reviewable, and testable.
5. Update documentation only where the runtime flow truly changed or needs clearer verification wording.
6. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. verify the Users & Devices route-protection and relock flow still behaves exactly as intended
2. tighten any final release-confidence gaps found in the active trust flow
3. align the user guide and manual checklist with the real runtime flow
4. strengthen focused proof where practical without widening the module into new feature work

Recommended first focus:

- manual verification alignment
- route and session confidence
- operator handoff clarity

## Out of Scope

Do not add these in this slice unless they are already trivial once the verification work is done:

- cloud or account-linked workflow
- external authentication
- new major admin surfaces
- unrelated dashboard redesign
- broader integration work
- speculative security expansion beyond the current local model

## Expected Result

After this slice:

1. the module’s locked, unlocked, relock, and restart flow is easier to verify
2. the guide and checklist match the real app more closely
3. remaining trust-flow ambiguity is reduced without adding unnecessary new UI
4. Users & Devices feels more ready for a broader release-confidence review

## Definition of Done

This slice is only done when:

1. the relevant Users & Devices route, PIN, and screen tests still pass
2. any touched runtime flow is manually checked against `users_devices_manual_test_checklist.md`
3. guide wording and checklist wording match the real route flow where updated
4. `flutter analyze` passes
5. focused `flutter test` passes
6. `flutter build windows` passes if runtime code changed
