# Local Build Guide

This guide covers the current V0.1 app shell build for the New Earth Command Dashboard.

## Requirements

- Flutter SDK installed
- Dart SDK from Flutter
- Android Studio, VS Code, or another Flutter-capable editor
- An Android emulator, connected Android device, or desktop Flutter target

## First Setup

From the project root:

```powershell
flutter pub get
```

## Quality Checks

Run the analyzer:

```powershell
flutter analyze
```

Run widget tests:

```powershell
flutter test
```

## Run Locally

List available devices:

```powershell
flutter devices
```

Run on the selected/default device:

```powershell
flutter run
```

Run on Windows desktop, if enabled:

```powershell
flutter run -d windows
```

## Current Build Scope

The current committed build is the first app shell only:

- Material 3 New Earth theme
- `go_router` navigation
- Bottom navigation for Dashboard, Projects, Tasks, Planner, and More
- Placeholder screens for Dashboard, Projects, Tasks, Planner, Journal, Learning, Content, Business, Wellbeing, Inbox, and Settings
- More screen links to supporting modules
- Dashboard placeholder cards for the first daily command centre layout

No database, AI features, cloud sync, login, or external integrations are included in this build.

## Current Verification Status

The app shell has been checked with:

```powershell
flutter analyze
flutter test
```

Both commands pass at the time this guide was written.
