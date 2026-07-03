# TASK - Omega Knowledge Engine Output Health

## Status

Ready to start.

The Omega Knowledge Engine is already live enough to scan and explain repos safely.
The next useful slice is to make the output previews and health checks feel clearer so the user can trust what is ready, what is missing, and what to inspect next.

## Goal

Clarify the Omega Knowledge Engine overview by improving:

- repository validation
- output previews
- output health checks
- missing-output and missing-repo guidance

This slice sits inside:

- `Omega Knowledge Engine`
- `Repository Validation`
- `Output Preview and Health`
- `Repo Upgrade Program`

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `modules/26_OMEGA_KNOWLEDGE_ENGINE/docs/FSD_OMEGA_KNOWLEDGE_ENGINE.md`
- `docs/fsd/10_testing_release.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`
- `docs/roadmap/major_upgrade_review.md`
- `docs/roadmap/dashboard_future_roadmap.md`
- `modules/26_OMEGA_KNOWLEDGE_ENGINE/README.md`

Pay special attention to:

- safe read-only defaults
- repository target visibility
- sample output preview clarity
- scan readiness wording
- output health and fallback states

## Requirements

1. Keep the app local-first and offline-first.
2. Keep the engine read-only by default.
3. Keep wording calm, practical, and low-pressure.
4. Prefer explicit output health cues over counts alone.
5. Keep the slice small, reviewable, and testable.
6. Update documentation only where runtime flow or verification wording truly changed.
7. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. make repository validation clearer at a glance
2. make output previews easier to trust
3. make missing outputs and repo targets more obvious
4. keep the overview calm and readable

## Out of Scope

Do not add these in this slice unless they are already trivial once the clarity work is done:

- automatic source rewriting
- live repo scanning daemon
- AI automation
- broad module redesign
- live cloud integration

## Expected Result

After this slice:

1. the overview tells the user whether the engine is ready to scan
2. output previews show what is available and what still needs to be generated
3. missing repo targets or output files are easier to spot
4. the module feels safer and more grounded

## Definition of Done

This slice is only done when:

1. the relevant Knowledge Engine tests still pass
2. any touched runtime flow is checked against the module FSD
3. wording and runtime flow still match where updated
4. `flutter analyze` passes
5. focused `flutter test` passes
6. `flutter build windows` passes if runtime code changed
