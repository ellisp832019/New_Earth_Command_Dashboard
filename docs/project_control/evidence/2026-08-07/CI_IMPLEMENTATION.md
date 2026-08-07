# CI Implementation Evidence

- Date: 2026-08-07
- Branch: `ci/dashboard-github-actions-and-branch-controls-2026-08-07`
- Base branch: `feature/new-earth-dashboard-platform-control-hardening-2026-08-06`
- Base commit: `6718f5448fd652b2092426c4f199453df06e2f8b`

## What Was Added

- `.github/workflows/flutter_quality.yml`
- `.github/workflows/project_control_validation.yml`
- `.github/workflows/windows_release_build.yml`
- `docs/developer_guide/GENERATED_CODE_POLICY.md`
- `docs/developer_guide/GITHUB_ACTIONS_AND_BRANCH_PROTECTION.md`
- `docs/developer_guide/CI_LOCAL_REPRODUCTION.md`

## Current GitHub State

- No branch protection is configured on `main`.
- No branch protection is configured on the current integration branch.
- No rulesets were returned by the GitHub API.
- The required checks are now proven on GitHub for PR #7:
  - `Flutter Quality`
  - `Project Control Validation`
  - `Windows Release Build`

## Local Validation Completed Before Committing

- `flutter clean`
- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test --reporter expanded`
- `dart run tool/project_control.dart doctor`
- `dart run tool/project_control.dart scan`
- `dart run tool/project_control.dart validate`
- `dart run tool/project_control.dart report`
- `dart run tool/project_control.dart release-readiness`
- `flutter build windows --release`
- `git diff --check`

## Results

- Analyzer passed.
- Full test suite passed.
- Windows release build passed.
- Project-control `release-readiness` now resolves to `ready_with_conditions` after the GitHub CI evidence closed `R-003`.
- `project_control scan` refreshes timestamped generated evidence snapshots, so the CI validation workflow inspects those files and only fails on unexpected canonical YAML drift.
- GitHub Actions later passed on the latest PR head SHA `522a8dc802a756d5f2f0a1327e98d81597f8954e`.
- The remote runs confirmed the same three required checks:
  - `Flutter Quality`
  - `Project Control Validation`
  - `Windows Release Build`

## Generated-Code Policy

- Generated source is committed.
- CI should regenerate and fail if the tree drifts.

## Next Step

- Record the successful remote runs in the canonical CI evidence and close `R-003`.
