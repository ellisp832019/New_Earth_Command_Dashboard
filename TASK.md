# TASK - Users & Devices PIN And Onboarding Confidence

## Status

Ready to start.

The route-protection and locked-state honesty slice has completed.

The next active trust-hardening slice should deepen operator confidence in:

- failed unlock and timed lockout handling
- recovery and admin reset governance
- onboarding trust review and readiness summaries

## Goal

Make the PIN Registry and Device Onboarding screens feel like dependable local operator tools by surfacing lockout state, recovery posture, PIN event history, and device-trust follow-up more clearly.

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

- per-user PIN lifecycle clarity
- recovery and reset audit visibility
- onboarding readiness and trust review posture
- persistence and release verification discipline

## Requirements

1. Keep the app local-first and offline-first.
2. Keep wording calm, practical, and low-pressure.
3. Surface lockout and recovery state clearly without exposing unsafe shortcuts.
4. Show enough audit history for a local operator to understand recent PIN events.
5. Make onboarding trust follow-up feel actionable without overwhelming the screen.
6. Keep wording calm, practical, and low-pressure.
7. Keep changes small, reviewable, and testable.
8. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. improve lockout and recovery posture summaries in `PIN Registry`
2. add per-user PIN event visibility and clearer rotation guidance
3. tighten `Device Onboarding` with a trust review queue and clearer next-step summaries
4. prove the new operator panels with focused tests

Recommended first focus:

- lockout countdown confidence
- recovery and reset governance
- onboarding trust review follow-up

## Out of Scope

Do not add these in this slice unless they are already trivial once the core work is done:

- cloud or account-linked workflow
- external authentication
- write-back beyond the existing local admin tools
- unrelated dashboard redesign

## Expected Result

After this slice:

1. operators can see which users are locked out, missing primary PINs, or carrying live recovery codes
2. recovery rotation and admin reset work feels clearer and more auditable
3. onboarding shows which devices still need trust review and why
4. the trust layer feels stronger without becoming noisy

## Definition of Done

This slice is only done when:

1. PIN Registry shows clearer lockout, recovery, and recent PIN-event posture
2. Device Onboarding shows a clearer trust review workspace
3. focused Users & Devices tests are added or updated where practical
5. `flutter analyze` passes
6. `flutter test` passes
7. `flutter build windows` passes if runtime code changed
