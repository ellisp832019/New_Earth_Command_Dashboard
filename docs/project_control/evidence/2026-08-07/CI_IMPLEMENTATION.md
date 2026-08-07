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
- Required checks are not yet configured because the workflow check names still need their first successful GitHub runs.

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
- Project-control `release-readiness` remained `not_ready` because `R-003` is still open.
- `project_control scan` refreshes timestamped generated evidence snapshots, so the CI validation workflow inspects those files and only fails on unexpected canonical YAML drift.

## Generated-Code Policy

- Generated source is committed.
- CI should regenerate and fail if the tree drifts.

## Next Step

- Push the CI branch and observe the first real GitHub Actions runs before deciding whether `R-003` can be resolved.
