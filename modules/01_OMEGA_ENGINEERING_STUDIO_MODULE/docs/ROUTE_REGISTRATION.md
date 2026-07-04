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
3. `lib/core/routing/app_launch_route.dart`
4. `lib/core/widgets/app_shell.dart`
5. `lib/features/modules/module_package_screen.dart`
6. `modules/01_OMEGA_ENGINEERING_STUDIO_MODULE/module_manifest.json`
7. Global module switcher in the desktop title bar

## Notes

- The module is local-first and mock-data-first.
- The dedicated package shell now opens at `/module-packages/01_OMEGA_ENGINEERING_STUDIO_MODULE`.
- The section routes still land on the engineering workspace shell for deep work.
- The title-bar module dropdown should open the package shell first, then expose the module home and section routes from there.
- Future hardening can split the package shell into deeper module-specific panels without changing the public package route.
- Omega Knowledge Engine and GAIA are exposed as integration-ready hooks, not live cloud dependencies.
