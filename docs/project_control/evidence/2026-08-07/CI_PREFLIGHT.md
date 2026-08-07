# CI Preflight

- Date: 2026-08-07
- Repository: `D:\Dev\Projects\New Earth - Command Dashboard`
- Base branch: `feature/new-earth-dashboard-platform-control-hardening-2026-08-06`
- Base commit: `6718f5448fd652b2092426c4f199453df06e2f8b`
- CI branch: `ci/dashboard-github-actions-and-branch-controls-2026-08-07`

## Current State

- GitHub Actions workflow inventory: none
- `.github/` directory: absent
- Current branch protection state:
  - `main`: not protected
  - `feature/new-earth-dashboard-platform-control-hardening-2026-08-06`: not protected
- Current required checks: none
- `R-003` status: open P1
- Release-readiness: `not_ready`

## Tooling

- Flutter: `3.41.7` stable
- Dart: `3.11.5`
- GitHub CLI: authenticated as `ellisp832019`
- Repository permission: `ADMIN`

## Chosen CI Environment

- Flutter quality and project-control validation: `ubuntu-latest`
- Windows release build: `windows-latest`
- Flutter SDK family: `3.41.7` stable

## Repository Requirements

- Package manager state: `flutter pub get`
- Build generation: `dart run build_runner build --delete-conflicting-outputs`
- Generated code policy: committed generated source is already tracked in the repository, so CI should regenerate and fail on drift.
- Desktop plugins currently in use: `window_manager`, `tray_manager`, `hotkey_manager`, `speech_to_text`
- Windows release path: `build/windows/x64/runner/Release/new_earth_command_dashboard.exe`
- Project-control CLI commands:
  - `dart run tool/project_control.dart doctor`
  - `dart run tool/project_control.dart scan`
  - `dart run tool/project_control.dart validate`
  - `dart run tool/project_control.dart report`
  - `dart run tool/project_control.dart diff`
  - `dart run tool/project_control.dart release-readiness`

## Local Verification Baseline

- `git status --short`
- `git diff --check`
- `flutter --version`
- `dart --version`
- `gh auth status`
- `gh api repos/ellisp832019/New_Earth_Command_Dashboard/branches/main/protection`
- `gh api repos/ellisp832019/New_Earth_Command_Dashboard/rulesets`
- `gh api repos/ellisp832019/New_Earth_Command_Dashboard/branches/feature/new-earth-dashboard-platform-control-hardening-2026-08-06/protection`

## Notes

- The repository currently has no established `.github/workflows` baseline.
- GitHub reports no branch protection on `main` or the current integration branch.
- The CI implementation must not assume branch protection or required checks exist until the real workflow names have been observed on GitHub.
- Windows release validation remains mandatory because the repository ships a Windows desktop executable.
