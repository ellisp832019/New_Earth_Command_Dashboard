# TASK - Users & Devices Persistence And Migration Hardening

## Status

Ready to start.

The export and migration health slice has completed.

The next active trust-hardening slice should deepen local operator confidence in:

- SQLite persistence confidence
- repeat-load migration stability
- proof that PIN and approval state survive local reloads cleanly

## Goal

Make the Users & Devices trust layer feel dependable under reload, restart, and migration conditions by proving that SQLite-first state stays stable and older data normalizes cleanly.

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
- SQLite-first migration confidence
- approval normalization on reload
- PIN persistence and lockout persistence
- persistence and release verification discipline

## Requirements

1. Keep the app local-first and offline-first.
2. Keep wording calm, practical, and low-pressure.
3. Keep persistence checks focused on real local operator risk.
4. Prefer repository and service proof over visual noise.
5. Keep seed fallback behaviour predictable and non-duplicating.
6. Keep wording calm, practical, and low-pressure.
7. Keep changes small, reviewable, and testable.
8. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. prove repeated repository loads do not duplicate seeded trust data
2. prove PIN state and lockout state survive a fresh service reload
3. prove migration health reflects the real SQLite table state
4. update the focused tests and guide wording only where needed

Recommended first focus:

- migration confidence
- repeat-load stability
- restart safety

## Out of Scope

Do not add these in this slice unless they are already trivial once the core work is done:

- cloud or account-linked workflow
- external authentication
- write-back beyond the existing local admin tools
- unrelated dashboard redesign

## Expected Result

After this slice:

1. repeated local loads stay stable without seed duplication
2. PIN and lockout state survive a fresh service round-trip
3. migration health remains honest about table presence and row counts
4. the SQLite-first trust layer feels safer to rely on day to day

## Definition of Done

This slice is only done when:

1. repository tests prove repeated loads stay stable
2. PIN registry tests prove PIN and lockout state survive a fresh reload
3. migration health is covered by focused persistence tests where practical
4. focused Users & Devices tests are added or updated where practical
5. `flutter analyze` passes
6. `flutter test` passes
7. `flutter build windows` passes if runtime code changed
