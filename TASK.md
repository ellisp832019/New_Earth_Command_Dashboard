# TASK - Users & Devices Reporting And Audit Hardening

## Status

Ready to start.

The PIN governance and onboarding confidence slice has completed.

The next active trust-hardening slice should deepen operator reporting confidence in:

- broader onboarding readiness reporting
- grouped audit visibility
- calmer risk summaries for failed unlocks, denials, and stale trust

## Goal

Make the `Onboarding Report` and `Audit Log` screens feel like dependable local operator reporting tools by surfacing readiness exceptions, grouped audit context, and latest-risk signals more clearly.

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
- grouped audit visibility by user, device, module, and action family
- latest-risk reporting for failed unlocks, denials, and stale trust
- persistence and release verification discipline

## Requirements

1. Keep the app local-first and offline-first.
2. Keep wording calm, practical, and low-pressure.
3. Keep readiness reporting calm, readable, and useful for handoff.
4. Show enough grouped audit history for a local operator to understand where trust pressure is building.
5. Make latest-risk signals actionable without turning the screen into a security panic board.
6. Keep wording calm, practical, and low-pressure.
7. Keep changes small, reviewable, and testable.
8. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. expand `Onboarding Report` into a broader readiness dashboard
2. add filters for archived, blocked, and exception-only users where useful
3. add grouped audit summaries and a latest-risk panel in `Audit Log`
4. prove the new reporting panels with focused tests

Recommended first focus:

- readiness dashboard clarity
- grouped audit visibility
- risk summary usefulness

## Out of Scope

Do not add these in this slice unless they are already trivial once the core work is done:

- cloud or account-linked workflow
- external authentication
- write-back beyond the existing local admin tools
- unrelated dashboard redesign

## Expected Result

After this slice:

1. operators can review onboarding readiness with clearer exception filters
2. audit events can be read by grouped context rather than only as a flat list
3. failed unlock and stale-trust signals are easier to spot quickly
4. the reporting layer feels stronger without becoming noisy

## Definition of Done

This slice is only done when:

1. Onboarding Report shows a broader readiness dashboard
2. Audit Log shows grouped summaries and latest-risk signals
3. focused Users & Devices tests are added or updated where practical
5. `flutter analyze` passes
6. `flutter test` passes
7. `flutter build windows` passes if runtime code changed
