# Testing Toolkit

This is the practical day-to-day testing guide for the dashboard.

Use it when:

- `flutter run` fails and you need a steady recovery loop
- widget tests start hanging or feeling unreliable
- analyzer passes but Windows build still fails
- you want the shortest safe verification path before a commit

For the formal release-style test plan, use:

- [`docs/fsd/10_testing_release.md`](../fsd/10_testing_release.md)
- [`docs/testing/test_plan.md`](../testing/test_plan.md)

## Calm default loop

For normal feature work:

1. Run `flutter analyze`
2. Run the smallest relevant test file
3. Run `flutter test` only when the touched area is stable
4. Run `flutter run -d windows` if the change is UI, routing, or platform-sensitive

Recommended examples:

```powershell
flutter analyze
flutter test test/widget_test.dart
flutter run -d windows
```

## Fast recovery order

If a build or test run goes wrong, use this order:

1. Stop any running app window first
2. Run `flutter analyze`
3. Run the smallest failing test file
4. Run full `flutter test`
5. Run `flutter run -d windows`

Why this order helps:

- analyzer catches syntax and type issues quickly
- one focused test file is easier to debug than the whole suite
- full test confirms there is no hidden regression
- Windows run proves the desktop target still boots

## When `flutter run -d windows` fails

Use this checklist.

### 1. Check if the app is already running

This repo often fails a Windows build when the app is still open.

Do this first:

- close the running dashboard window
- stop any active debug session in VS Code
- rerun the command

Then try:

```powershell
flutter run -d windows
```

### 2. Run analyzer before guessing

If the build log looks noisy, do not debug the long MSBuild output first.

Run:

```powershell
flutter analyze
```

If analyzer reports a Dart error, fix that before looking at Windows tooling.

### 3. Treat `INSTALL.vcxproj` failures carefully

If you see a long Windows error ending in `INSTALL.vcxproj`, it often means one of these:

- the app was still running
- a generated build artifact is stale
- there is an earlier Dart compile error hidden above

Use this sequence:

```powershell
flutter analyze
flutter test
flutter clean
flutter pub get
flutter run -d windows
```

Only use `flutter clean` when the lighter checks did not help.

## When tests hang

If a widget test appears to stall:

1. Run the single failing test with `--plain-name`
2. Run the whole test file
3. Look for one test file doing too much route, database, and UI setup at once
4. Split secondary flows into a separate file if needed
5. Replace heavy seed setup with tiny explicit fixtures when possible

Useful commands:

```powershell
flutter test test/widget_test.dart --plain-name "journal screen can create a linked entry"
flutter test test/widget_test.dart
flutter test test/widget_secondary_flows_test.dart
```

Good signs:

- one test passes alone but hangs inside the larger file
- a seed helper loads far more data than the test actually needs
- route-heavy flows cluster in one oversized widget file

## Analyzer vs build

Use this rule:

- if `flutter analyze` fails, fix that first
- if `flutter analyze` passes and Windows build fails, check runtime/process issues next

In this project, analyzer is usually the fastest truth source for:

- missing imports
- wrong method names
- null-safety mistakes
- syntax errors
- renamed widgets or helpers

## Smallest safe verification levels

Choose the smallest level that fits the change.

### Level 1 - documentation only

No Flutter verification needed.

### Level 2 - small Dart logic change

Run:

```powershell
flutter analyze
flutter test path/to/relevant_test.dart
```

### Level 3 - widget or route change

Run:

```powershell
flutter analyze
flutter test path/to/relevant_widget_test.dart
flutter run -d windows
```

### Level 4 - shared UI or shell change

Run:

```powershell
flutter analyze
flutter test
flutter run -d windows
```

## Before committing

Use this short checklist:

1. `flutter analyze` passes
2. relevant focused tests pass
3. full `flutter test` passes if shared flows changed
4. Windows app boots if desktop UI changed
5. `git status --short` only shows the files you expect

## If you need a release-style sweep

Use:

```powershell
./scripts/run_release_readiness.ps1
```

That is the calmer way to do:

- analyzer
- tests
- Windows build

with logs saved into `tmp/release_readiness`.

## Recommended habits for this repo

- prefer focused test files over one giant catch-all widget file
- avoid heavy seed setup in tests unless the test really needs it
- close the running desktop app before retrying Windows builds
- keep commits small enough that one failed run points to one clear slice
- do not trust a green analyzer alone for desktop route changes

## Best command sets

### Daily feature loop

```powershell
flutter analyze
flutter test test/widget_test.dart
flutter run -d windows
```

### Shared-flow loop

```powershell
flutter analyze
flutter test
flutter run -d windows
```

### Hard reset loop

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Use the hard reset loop only when the lighter loops stop making sense.
