# B7B Dashboard Integration Evidence

## Scope

This document records the Dashboard-side integration of the GAIA v0.9 read-only Project Officer summaries.

## Baselines

- Dashboard repository: `ellisp832019/New_Earth_Command_Dashboard`
- Dashboard worktree: `D:\Dev\Worktrees\New-Earth-Command-Dashboard-GAIA-B7B`
- Dashboard branch: `integration/gaia-v0.9-b7-read-only-summaries`
- Dashboard starting SHA: `a0880a136db7e9a6714e016d054e2a887e3f9475`
- GAIA source repository: `ellisp832019/New-Earth-AI-Employee`
- GAIA source SHA: `9bbfa978e7d5a1c2cb30be27128691ce187e758f`
- GAIA phase: `v0.9 B7A`

## Dependency Mechanism

The Dashboard consumes the official GAIA packages through pinned git dependencies in `pubspec.yaml` and `pubspec.lock`:

- `gaia_dashboard_module`
- `gaia_integration_client`

## Host Adapter

- `lib/features/gaia/application/gaia_employee_providers.dart`
- `lib/features/gaia/presentation/gaia_employee_screen.dart`

The host screen keeps the surface read-only and embeds `GaiaDashboardView` directly.

## Navigation Integration

- GAIA entry point: `RouteNames.gaiaEmployee`
- dashboard menu entry: `MoreScreen`
- host shell: `WorkspaceShell`

## Authority Boundary

- read-only Project Officer summaries only
- no approval control
- no rejection control
- no handoff mutation
- no execution control
- no Codex execution
- no direct GAIA database access

## Compatibility and Safety

- capability gating remains enforced by the GAIA module
- backend unavailable and incompatible states remain explicit
- stale data remains labelled stale
- unknown health is not treated as healthy

## Validation Evidence

- host widget tests updated to exercise the Project Officer tab
- `flutter test` passed across the repository
- `flutter build windows --release` passed and produced `build/windows/x64/runner/Release/new_earth_command_dashboard.exe`
- Windows smoke check passed for a 10-second hidden launch window
- smoke executable SHA-256: `17BB8585AAD854D4CB74DF53263170C66F2597F5BDF68E728CDCC6CAB7FE3400`
- `dart run tool/project_control.dart validate` returned successfully

## External Repository Safety

- GAIA repository remained read-only
- MicroGrow repository remained read-only
- the original Dashboard worktree was not modified

## Rollback

Reverting the git dependency refs restores the prior GAIA integration surface without changing the Dashboard shell architecture.
