# GitHub Actions and Branch Protection

This repository now uses a simple CI split:

## Workflows

### Flutter Quality

- File: `.github/workflows/flutter_quality.yml`
- Trigger: `pull_request` and `push`
- Runner: `ubuntu-latest`
- Job name: `Flutter Quality`
- Purpose: fast source-quality gate
- Steps:
  - checkout
  - Flutter setup
  - `flutter pub get`
  - `dart run build_runner build --delete-conflicting-outputs`
  - `dart format --output=none --set-exit-if-changed lib test tool`
  - `flutter analyze`
  - `flutter test --reporter expanded`

### Project Control Validation

- File: `.github/workflows/project_control_validation.yml`
- Trigger: `pull_request` and `push`
- Runner: `ubuntu-latest`
- Job name: `Project Control Validation`
- Purpose: validate the canonical governance records
- Steps:
  - checkout
  - Flutter setup
  - `flutter pub get`
  - `dart run tool/project_control.dart doctor`
  - `dart run tool/project_control.dart scan`
  - inspect the refreshed generated evidence snapshots via `git status --short`
  - fail only if the canonical project-control YAML changes during validation
  - `dart run tool/project_control.dart validate`
  - `dart run tool/project_control.dart report`
  - `dart run tool/project_control.dart release-readiness`

### Windows Release Build

- File: `.github/workflows/windows_release_build.yml`
- Trigger: `pull_request` and `push`
- Runner: `windows-latest`
- Job name: `Windows Release Build`
- Purpose: prove the Windows desktop release build and record the build hash
- Steps:
  - checkout
  - Flutter setup
  - `flutter pub get`
  - `dart run build_runner build --delete-conflicting-outputs`
  - `dart format --output=none --set-exit-if-changed lib test tool`
  - `flutter analyze`
  - `flutter test`
  - `flutter build windows --release`
  - executable hash recording
  - artifact upload

## Runner Choice

- `ubuntu-latest` is used for the source-quality and project-control gates because the codebase and tests run cross-platform and do not need Windows-only desktop packaging to validate logic and governance.
- `windows-latest` is required for the release-build gate because the repository ships a Windows desktop executable and the hash evidence must come from the real Windows build.

## Caching

- Flutter SDK and pub cache are handled through `subosito/flutter-action` with caching enabled.
- Build outputs are not cached.
- Databases and generated release binaries are not cached.

## Current Branch Protection State

- `main`: not protected
- `feature/new-earth-dashboard-platform-control-hardening-2026-08-06`: not protected
- No required checks are configured yet

## Required Checks To Use Later

Use the exact GitHub check names produced by the workflow jobs:

- `Flutter Quality`
- `Project Control Validation`
- `Windows Release Build`

Do not configure required checks until the workflows have actually run on GitHub and those names have been observed there.

## Branch Policy

Recommended long-term shape:

- `main`
  - stable integration and release history
- `feature/new-earth-dashboard-platform-control-hardening-2026-08-06`
  - temporary controlled integration branch for this hardening work
- `feature/*`, `fix/*`, `security/*`, `ci/*`
  - short-lived branches for focused changes

## Protection Guidance

For `main`, the eventual policy should include:

- require pull requests
- require required status checks
- require branches to be up to date before merging
- block force pushes
- block deletions
- require conversation resolution

For the temporary integration branch, apply a lighter policy only if it is safe to do so and only after the workflow check names are proven.

## Current Limitation

GitHub reported no branch protection and no rulesets at the time of this review, so this document is advisory until repository settings are configured.
