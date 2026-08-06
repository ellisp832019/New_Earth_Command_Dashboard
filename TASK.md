# TASK - 01_OMEGA_ENGINEERING_STUDIO_MODULE

## Status

Ready to start.

## Goal

Build and harden the Omega Engineering Studio as a calm, local-first Omega-standard module with mock data, a feature-first architecture, a shared package shell, and rendered visual assets.

## Source of Truth

Read these files first:

- `docs/fsd/00_master_index.md`
- `docs/fsd/03_user_roles_navigation.md`
- `docs/fsd/04_screen_specification.md`
- `docs/fsd/05_data_model.md`
- `docs/fsd/08_technical_architecture.md`
- `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/README.md`
- `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/docs/FEATURE_SPECIFICATION.md`
- `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/docs/ARCHITECTURE.md`
- `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/docs/ROUTE_REGISTRATION.md`
- `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/docs/DEVELOPER_NOTES.md`
- `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/docs/TODO.md`

## Requirements

1. Keep the build local-first and offline-first.
2. Use mock data first.
3. Preserve the calm New Earth visual language.
4. Keep Omega Knowledge Engine and GAIA as integration-ready hooks only.
5. Keep the feature architecture clean and reusable.
6. Keep the shared package shell and module launcher aligned with the main dashboard.
7. Use rendered PNG assets for visual documentation, not golden snapshot tests.
8. Add or maintain route registration, tests, and docs as the module evolves.
9. Verify analyzer and Windows build honestly.

## Current Slice

This slice should continue the engineering module hardening work:

1. keep the package shell and section routes aligned with the main dashboard
2. refine the feature-first domain, data, application, and presentation layers as needed
3. keep the rendered PNG visuals and documentation in sync with the current UI
4. maintain mock data coverage for projects, circuits, PCBs, firmware, devices, inventory, experiments, validation, manufacturing, and documents
5. keep the route registry, module manifest, and navigation entry consistent
6. verify `flutter analyze` and `flutter build windows`

## Out of Scope

Do not add cloud sync, authentication, or live integrations yet.

## Definition of Done

This task is done when:

1. the engineering module opens cleanly from the dashboard or module hub
2. the core engineering tabs render with mock data
3. the search, filters, and progress placeholders work locally
4. `flutter analyze` passes
5. `flutter build windows` passes
