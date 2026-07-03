# TASK - Omega Knowledge Engine Settings and Discovery

## Status

Ready to start.

The output-health slice is done.
The next useful slice is to make the Knowledge Engine settings easier to trust and make the module discovery path clearer from the docs and module surfaces.

## Goal

Improve the Knowledge Engine by clarifying:

- current settings and local paths
- Module Hub / More discovery cues
- the repo-wide upgrade position in the docs

This slice sits inside:

- `Omega Knowledge Engine`
- `Module Discovery`
- `Repo Upgrade Program`
- `Major Upgrade Review`

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `modules/26_OMEGA_KNOWLEDGE_ENGINE/docs/FSD_OMEGA_KNOWLEDGE_ENGINE.md`
- `modules/26_OMEGA_KNOWLEDGE_ENGINE/README.md`
- `docs/roadmap/major_upgrade_review.md`
- `docs/roadmap/dashboard_future_roadmap.md`
- `docs/fsd/12_major_upgrade_plan.md`
- `docs/fsd/13_upgrade_execution_plan.md`

Pay special attention to:

- safe read-only defaults
- current local path settings
- where the module is surfaced from
- where the app is in the broader upgrade program

## Requirements

1. Keep the app local-first and offline-first.
2. Keep the engine read-only by default.
3. Keep wording calm, practical, and low-pressure.
4. Keep discovery simple and obvious.
5. Keep the slice small, reviewable, and testable.
6. Update documentation only where the runtime flow or upgrade guidance truly changed.
7. If runtime behaviour changes, verify analyzer, tests, and Windows build honestly.

## Slice Scope

This slice should focus on the most useful minimum:

1. make the settings tab explain the current local path posture more clearly
2. make the module discovery path easier to trust from the docs
3. refresh the major-upgrade review wording if needed

## Out of Scope

Do not add these in this slice unless they are already trivial once the discovery work is done:

- automatic source rewriting
- live repo scanning daemon
- AI automation
- broad module redesign
- live cloud integration

## Expected Result

After this slice:

1. the user can see what paths the engine will use before scanning
2. the module is easier to discover from the dashboard surfaces and docs
3. the repo-wide upgrade position is clearer without adding noise

## Definition of Done

This slice is only done when:

1. the relevant Knowledge Engine tests still pass
2. any touched runtime flow is checked against the module FSD
3. wording and runtime flow still match where updated
4. `flutter analyze` passes
5. focused `flutter test` passes
6. `flutter build windows` passes if runtime code changed
