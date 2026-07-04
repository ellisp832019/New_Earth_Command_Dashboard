# 01 OMEGA Engineering Studio

Central engineering workspace for the New Earth Omega Dashboard.

## What is included

- Engineering Dashboard
- Projects
- Circuit Library
- PCB Manager
- Firmware Centre
- Device Fleet
- Component Inventory
- Experiment Lab
- Test & Validation
- Manufacturing
- Documentation
- Engineering Settings

## Local-first contract

- Mock data first
- Offline-first
- No cloud sync yet
- No auth gate added in this slice
- Integration-ready hooks for Omega Knowledge Engine and GAIA
- The module now has a standardized package shell route for dedicated windows.

## Source files

- Manifest: `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/module_manifest.json`
- Route notes: `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/docs/ROUTE_REGISTRATION.md`
- Developer notes: `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/docs/DEVELOPER_NOTES.md`
- TODO list: `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/docs/TODO.md`
- The app title bar now includes a module switcher that uses the local module registry.
- Dedicated windows launch through the shared package route at `/module-packages/01_OMEGA_ENGINEERING_STUDIO_MODULE`.

## Rendered assets

Rendered UI baselines for the module live under:

- `test/features/omega_engineering_studio/goldens/`
- `test/features/omega_engineering_studio/goldens/sections/`

Regenerate them with:

```bash
flutter test test/features/omega_engineering_studio --update-goldens
```
