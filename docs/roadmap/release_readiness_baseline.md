# Release Readiness Baseline

This baseline captures the first practical run of the release-readiness helper and the main findings it surfaced.

## Baseline Date

2026-06-25

## Commands Introduced

- `scripts/run_release_readiness.ps1`

Primary intended usage:

```powershell
./scripts/run_release_readiness.ps1
```

Safer first pass while investigating:

```powershell
./scripts/run_release_readiness.ps1 -SkipWindowsBuild
```

## What The Helper Does

- stops a running dashboard process by default
- runs `flutter analyze`
- runs `flutter test`
- optionally runs `flutter build windows`
- stores logs in `tmp/release_readiness`

## Baseline Findings

### 1. Analyzer

Status:

- improved to clean after fixing small string interpolation issues in Company Command Centre timestamp helpers

Files touched during cleanup:

- `lib/features/company_command_centre/data/company_command_centre_report_service.dart`
- `lib/features/company_command_centre/data/company_command_centre_write_service.dart`

### 2. Widget test suite

Status:

- not yet release-clean

Observed issue:

- the widget suite reaches `planner saves evening review fields to local plan`
- then a Knowledge Library API call returns `400` from `http://127.0.0.1:8787/health`

Relevant files:

- `test/widget_test.dart`
- `lib/features/knowledge_library/data/knowledge_library_repository.dart`
- `lib/features/knowledge_library/presentation/knowledge_library_dock_host.dart`

Meaning:

- at least one test path still depends on a live or semi-live Knowledge Library health surface instead of remaining isolated in the widget environment

### 3. Database warning during tests

Status:

- warning observed

Observed issue:

- multiple `AppDatabase` instances are being created during tests with the same executor family pattern

Meaning:

- this may not be the first bug to fix, but it is a release-readiness smell and should be cleaned up during test hardening

### 4. Windows build behavior

Status:

- still vulnerable to the known `INSTALL.vcxproj` / CMake install-stage failure when Windows runner state is not calm

Mitigation now added:

- the helper stops a running `new_earth_command_dashboard` process before build checks unless explicitly told not to

Meaning:

- this improves repeatability, but the repo still needs one clean release-build verification pass after the test suite is steadier

## Current Read

The release-readiness pass has started successfully because it now has:

- a repeatable helper
- a written runbook
- a first baseline
- a first concrete failing area to harden

The repo is not yet release-clean because:

- widget tests are still leaking into Knowledge Library health behavior
- the Windows release-build path is not yet consistently calm

## Best Next Release-Readiness Slice

1. Isolate Knowledge Library dependencies inside widget tests
2. Re-run `./scripts/run_release_readiness.ps1 -SkipWindowsBuild`
3. Once tests are calmer, run the full helper including Windows build
4. Then move into manual restart-persistence verification
