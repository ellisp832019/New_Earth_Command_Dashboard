# TASK - 24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB

## Status

Ready to start.

## Goal

Build the Education & Learning Hub as a calm, local-first Omega-standard module with mock data, a feature-first architecture, and a complete UI shell for the core learning workspaces.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/04_screen_specification.md`
- `modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB/README.md`
- `modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB/02_UI_UX/SCREEN_LIST.md`
- `modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB/15_CODEX/CODEX_INCREMENTAL_BUILD_STEPS.md`
- `modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB/19_DEPLOYMENT/ADD_TO_DASHBOARD.md`
- `modules/24_NEW_EARTH_EDUCATION_AND_LEARNING_HUB/20_DOCUMENTATION/USER_GUIDE.md`

## Requirements

1. Keep the build local-first and offline-first.
2. Use mock data first.
3. Preserve the calm New Earth visual language.
4. Create clear placeholder flows for AI tutor and external integrations.
5. Keep the feature architecture clean and reusable.
6. Add route registration, module manifest, navigation entry, tests, and docs.
7. Verify analyzer and Windows build honestly.

## Current Slice

This slice should complete the first useful module shell:

1. module manifest and route registration
2. domain models, repository, and services
3. Education Dashboard and the core tabs
4. mock data loading and placeholder integration hooks
5. basic tests and documentation updates

## Out of Scope

Do not add cloud sync, authentication, or live integrations yet.

## Definition of Done

This task is done when:

1. the module opens from the dashboard or module hub
2. the core learning tabs render with mock data
3. the search, filters, and progress placeholders work locally
4. `flutter analyze` passes
5. `flutter build windows` passes
