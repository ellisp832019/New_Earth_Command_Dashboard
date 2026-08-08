# GAIA v0.9 Slice B Project Control Context Adapter Acceptance

Date: 2026-08-08

Branch: `feature/gaia-v0.9-project-control-context-adapter-2026-08-08`

## Scope

This evidence records the Dashboard-side Project Control context adapter slice.

The slice is read-only and repository-relative. It reads allowlisted Project Control sources and separates canonical records from generated evidence without treating recorded branch or commit values as live Git truth.

## Validation

Toolchain:

- Flutter 3.41.7
- Dart 3.11.5

Commands run successfully:

- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test`
- `dart run tool/project_control.dart validate`
- `flutter build windows --release`

Focused adapter tests:

- loads canonical registries and generated evidence from allowlisted sources
- keeps generated repository health as recorded evidence, not live Git truth
- rejects missing allowlisted sources explicitly
- rejects malformed allowlisted sources explicitly
- exposes read-only collections

## Notes

- No unrelated generated registrant churn was retained in the branch.
- The adapter uses only allowlisted Project Control files and generated evidence files.
- The generated repository health and current state records remain historical evidence only.

