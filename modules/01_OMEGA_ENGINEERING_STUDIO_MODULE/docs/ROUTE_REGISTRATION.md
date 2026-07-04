# Route Registration Notes

## Primary route

- `/modules/omega-engineering-studio`

## Section routes

- `/modules/omega-engineering-studio/projects`
- `/modules/omega-engineering-studio/circuit-library`
- `/modules/omega-engineering-studio/pcb-manager`
- `/modules/omega-engineering-studio/firmware-centre`
- `/modules/omega-engineering-studio/device-fleet`
- `/modules/omega-engineering-studio/component-inventory`
- `/modules/omega-engineering-studio/experiment-lab`
- `/modules/omega-engineering-studio/test-validation`
- `/modules/omega-engineering-studio/manufacturing`
- `/modules/omega-engineering-studio/documentation`
- `/modules/omega-engineering-studio/settings`

## App registration points

1. `lib/core/routing/route_names.dart`
2. `lib/core/routing/app_router.dart`
3. `lib/features/more/presentation/more_screen.dart`
4. `lib/core/widgets/app_shell.dart`
5. `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/module_manifest.json`
6. Global module switcher in the desktop title bar

## Notes

- The module is local-first and mock-data-first.
- The section routes all land on the same engineering workspace shell.
- The title-bar module dropdown should open `/modules/omega-engineering-studio` for the module home and any registered section route for deeper workspace views.
- Future hardening can split these routes into dedicated screens without changing the public paths.
- Omega Knowledge Engine and GAIA are exposed as integration-ready hooks, not live cloud dependencies.
