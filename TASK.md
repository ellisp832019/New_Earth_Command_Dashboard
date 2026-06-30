# TASK - Users & Devices Export And Migration Health

## Status

Ready to start.

The reporting and audit hardening slice has completed.

The next active trust-hardening slice should deepen local operator confidence in:

- exportable readiness summaries
- calmer incident reporting for audit review
- SQLite migration health visibility for local support

## Goal

Make the `Onboarding Report`, `Audit Log`, and module home feel like dependable local operator support tools by adding exportable summaries and a clear migration-health view for the SQLite-first trust layer.

This slice sits inside the wider upgrade streams:

- `Users & Devices Security Hardening`
- `Users & Devices Trust Completion`
- `Foundation Hardening`

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/10_testing_release.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `modules/01_USERS_AND_DEVICES_CONTROL/docs/UPGRADE_PLAN_NEXT_SLICE.md`

Pay special attention to:

- onboarding readiness and trust review posture
- calmer export and handoff patterns
- SQLite-first migration confidence
- seed fallback visibility for local support
- persistence and release verification discipline

## Requirements

1. Keep the app local-first and offline-first.
2. Keep wording calm, practical, and low-pressure.
3. Keep exported summaries readable enough for handoff and review.
4. Make migration posture understandable without requiring database knowledge.
5. Keep file export local and review-first.
6. Keep wording calm, practical, and low-pressure.
7. Keep changes small, reviewable, and testable.
8. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. add a local readiness summary export from `Onboarding Report`
2. add a calmer incident summary export from `Audit Log`
3. add a small `Migration Health` admin screen for SQLite-first support
4. surface the migration screen from the Users & Devices module home
5. prove the new export and migration panels with focused tests

Recommended first focus:

- export clarity
- migration confidence
- local support usefulness

## Out of Scope

Do not add these in this slice unless they are already trivial once the core work is done:

- cloud or account-linked workflow
- external authentication
- write-back beyond the existing local admin tools
- unrelated dashboard redesign

## Expected Result

After this slice:

1. operators can export a calm readiness summary without leaving the app
2. audit review can produce a calmer local incident summary
3. local support can inspect whether the Users & Devices trust layer is seeded and living in SQLite as expected
4. the reporting and migration layer feels stronger without becoming noisy

## Definition of Done

This slice is only done when:

1. Onboarding Report exposes a local readiness export path
2. Audit Log exposes a local incident export path
3. Users & Devices shows a dedicated Migration Health support screen
3. focused Users & Devices tests are added or updated where practical
5. `flutter analyze` passes
6. `flutter test` passes
7. `flutter build windows` passes if runtime code changed
