# GAIA v0.8 Post-Merge Acceptance Fix

## Baseline

- Dashboard repository: `D:\Dev\Verification\New-Earth-Dashboard-GAIA-v0.8-main`
- Repair worktree: `fix/gaia-v0.8-post-merge-acceptance`
- Starting SHA: `730046db9facf55d33da826c08a01ce666a7650f`

## Analyzer Regression

- Added the missing `showGaiaEmployeeSurface` argument in the two affected `AppSetting` fixtures inside `test/widget_test.dart`.
- The added value is `false` in both fixtures.
- That disabled-state default matches the test harness intent, because the GAIA surface is only shown when the feature flag is explicitly enabled.

## Windows Startup Regression

- The repaired startup path guards the optional desktop-window setup in `lib/main.dart` against `MissingPluginException`.
- The guard wraps the optional desktop shell flow only, including desktop startup initialisation and the window setup path.
- The fallback is to log the unavailability of the optional desktop shell plugins and continue into `runApp`.
- Unrelated startup work remains outside the catch block, so database setup, routing, service creation, GAIA integration, and other Flutter startup errors are not swallowed.
- The historical closeout prompt referenced a `window_size` / `setWindowFrame` failure class, but this worktree does not contain a live `window_size` dependency. The validated fix here is the guarded optional desktop-window startup path.

## Validation

- Dart formatting: passed for `lib/main.dart` and `test/widget_test.dart`
- `flutter analyze`: passed with no issues
- Focused GAIA test result:
  - `flutter test test/features/gaia/gaia_employee_screen_test.dart --reporter expanded`
  - passed
- Relevant startup test result:
  - `flutter test test/features/security/security_startup_screen_test.dart --reporter expanded`
  - passed
- Windows release build:
  - passed
- Executable path:
  - `D:\Dev\Verification\New-Earth-Dashboard-GAIA-v0.8-main\build\windows\x64\runner\Release\new_earth_command_dashboard.exe`
- Executable SHA-256:
  - `BD53BBC02E82F10D84D33CF25A74D9FB0CB56528DDCA5F5F710338309052C210`
- Executable size:
  - `92160` bytes
- 10-second smoke test:
  - passed

## Residual Widget Suite

- Exact command:
  - `flutter test test/widget_test.dart --reporter expanded`
- Result:
  - 48 passed, 7 failed
- Residual failures and classification:
  - `app shell opens to dashboard` - clearly pre-existing stale expectation
  - `ctrl k opens the command palette from the dashboard` - clearly pre-existing stale expectation
  - `more screen links to supporting screens` - clearly pre-existing stale expectation
  - `projects screen shows seeded project cards` - clearly pre-existing stale expectation
  - `projects route opens the projects hub` - clearly pre-existing stale expectation
  - `tasks screen shows local task cards` - clearly pre-existing stale expectation
  - `planner screen shows today plan summary` - clearly pre-existing stale expectation
- These unrelated widget expectations were intentionally deferred to a separate reconciliation branch.

## Excluded Worktree Churn

- Reviewed but excluded unless proven necessary:
  - `linux/flutter/generated_plugin_registrant.cc`
  - `linux/flutter/generated_plugin_registrant.h`
  - `linux/flutter/generated_plugins.cmake`
  - `macos/Flutter/GeneratedPluginRegistrant.swift`
  - `windows/flutter/generated_plugin_registrant.cc`
  - `windows/flutter/generated_plugin_registrant.h`
  - `windows/flutter/generated_plugins.cmake`
  - `assets/treasury/_demo_finance/`
  - `build/`
- The external widget residual capture was also kept outside Git:
  - `D:\Dev\Backups\GAIA-v0.8-widget-test-residuals.txt`

## Outcome

The focused GAIA post-merge acceptance gate is passed with unrelated known test residuals.
