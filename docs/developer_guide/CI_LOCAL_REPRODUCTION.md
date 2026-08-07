# CI Local Reproduction

Use these commands to reproduce the GitHub Actions jobs locally.

## Flutter Quality

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

## Project Control Validation

```powershell
flutter pub get
dart run tool/project_control.dart doctor
dart run tool/project_control.dart scan
git status --short -- project_control/generated docs/project_control/evidence
dart run tool/project_control.dart validate
dart run tool/project_control.dart report
dart run tool/project_control.dart release-readiness
```

Notes:

- `release-readiness` may legitimately report `not_ready` while `R-003` remains open.
- `scan` refreshes the timestamped generated evidence snapshots, so the workflow treats those files as reviewable output and only fails if the canonical project-control YAML changes.

## Windows Release Build

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
flutter build windows --release
Get-FileHash ".\build\windows\x64\runner\Release\new_earth_command_dashboard.exe" -Algorithm SHA256
```

If you want the same artifact metadata written locally, create:

```powershell
New-Item -ItemType Directory -Force ci-artifacts/windows-release | Out-Null
```

and write a `SHA256.txt` file containing:

- commit SHA
- workflow run identifier
- executable filename
- SHA-256
- build timestamp

## Troubleshooting

- If `flutter clean` or `dart run` fails because a native asset file is locked, stop lingering Dart/Flutter processes and retry the smallest command that failed.
- If the Windows build fails, close any running desktop app windows before retrying.
- If tests fail, rerun the single failing test file first, then the full suite.
