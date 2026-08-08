# GAIA v0.9 Slice C Local Git Live-State Adapter Acceptance

Date: 2026-08-08

Branch: `feature/gaia-v0.9-local-git-live-state-adapter-2026-08-08`

## Scope

This evidence records the Dashboard-side local Git live-state adapter slice.

The slice is read-only and repository-relative. It observes live Git state from the local repository only and does not use GitHub, backend services, or mutation-capable Git commands in production code.

## Live Git Fields Observed

- repository root
- current HEAD commit
- current branch or detached HEAD
- working tree cleanliness
- upstream branch when configured
- ahead / behind counts when available
- observation timestamp
- remote identity when safely available locally

## Validation

Toolchain:

- Flutter 3.41.7
- Dart 3.11.5

Commands run successfully:

- `flutter pub get`
- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test`
- `dart run tool/project_control.dart validate`
- `flutter build windows --release`

Focused adapter tests:

- observes a real temp repository without mutating it
- skips upstream and ahead-behind reads for detached heads
- reports status failures as unknown working tree state
- rejects repository root mismatches

## CI Verification

PR: `#15`

Latest head SHA: `31b737f6e4ca2634fb144f6e5d5c23e05fe92f52`

Verified GitHub Actions runs on that exact head:

- `Flutter Quality`
  - Run: `31255211317`
  - Status: pass
- `Project Control Validation`
  - Run: `31255211331`
  - Status: pass
- `Windows Release Build`
  - Run: `31255211335`
  - Status: pass

## Notes

- The generated Flutter plugin registrant files were inspected after local validation.
- Their drift was limited to line-ending normalization and was restored before closeout.
- `window_manager` remained present.
- `window_size` was not added or removed.
- The `_demo_finance` path used by `TreasuryFolderService` is runtime-generated fallback content, not canonical source or fixture data.
- No UI wiring, GitHub integration, or mutation-capable Git commands were added in this slice.
