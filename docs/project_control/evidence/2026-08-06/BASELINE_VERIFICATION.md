# Baseline Verification

Date: 2026-08-06

## Scope

Repository baseline verification after the `feature/new-earth-dashboard-platform-control-hardening-2026-08-06` checkpoint and before canonical project-control work.

## Environment

- Repository path: `D:\Dev\Projects\New Earth - Command Dashboard`
- Branch: `feature/new-earth-dashboard-platform-control-hardening-2026-08-06`
- Commit at start of baseline lane: `ed074ebf91de97a55fdc0c9cf69ae97eeef4fd67`

## Commands Run

```powershell
flutter --version
dart --version
flutter doctor -v
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
flutter build windows --release
```

## Results

- `flutter --version`: passed.
- `dart --version`: passed.
- `flutter doctor -v`: passed.
- `flutter clean`: passed.
- `flutter pub get`: passed.
- `dart run build_runner build --delete-conflicting-outputs`: passed, with a warning that `--delete-conflicting-outputs` is no longer used by the current build_runner invocation.
- `dart format --output=none --set-exit-if-changed lib test`: initially failed because many files required formatting changes, then passed after applying the formatter to the repository tree.
- `flutter analyze`: passed.
- `flutter test --reporter expanded`: passed on the final verified baseline run.
- `flutter build windows --release`: passed.

## Notes

- The repository was left with a local-only `.vscode/settings.json` excluded via `.git/info/exclude`; it was not committed.
- The full widget test suite is now green, and analyzer output is clean.
- The final passing test log is `docs/project_control/evidence/2026-08-06/logs/flutter_test_final_verified.log`.
