# Developer Workflow Toolkit

This repo includes a small local workflow toolkit to keep day-to-day Flutter work fast and predictable.

## VS Code Tasks

Use `Terminal > Run Task` and choose:

- `Flutter: quick analyze Omega + Modules`
- `Flutter: get + quick analyze`
- `Flutter: get + analyze + test`
- `Flutter: analyze full workspace`
- `Flutter: format project`
- `Flutter: pub get`
- `Flutter: clean`
- `Flutter: test`
- `Flutter: run Windows`
- `Flutter: run Chrome`
- `Flutter: build Windows`
- `Flutter: build Web`
- `Flutter: build all local`

## VS Code Shortcuts

Keyboard shortcuts are mapped for the common loops:

- `Ctrl+Alt+A` quick analyze
- `Ctrl+Alt+B` get, analyze, and test
- `Ctrl+Alt+F` format
- `Ctrl+Alt+T` test
- `Ctrl+Alt+R` run Windows
- `Ctrl+Alt+W` run Chrome
- `Ctrl+Alt+G` pub get
- `Ctrl+Alt+C` clean

## Debug Profiles

The Run and Debug panel includes:

- `Launch Windows`
- `Launch Chrome`

## Recommended Loop

1. Run `Flutter: pub get` if dependencies changed.
2. Run `Flutter: quick analyze Omega + Modules`.
3. Run `Flutter: test` if you touched logic or state.
4. Use `Launch Windows` or `Launch Chrome` for debugging.
5. Use `Flutter: analyze full workspace` when you want a wider sweep.
6. Use `Flutter: build all local` before a release-style smoke check.

## Notes

- The quick analyze task is intentionally narrow so it finishes faster.
- The full analyze task still exists when you want the whole repo checked.
- Flutter tasks now share a small local guard so one long-running Flutter job runs at a time.
- If you try to start a second analyze/test/build while one is already active, it will exit politely instead of spawning another runner.
- The guard applies to the VS Code tasks in this toolkit. Raw terminal commands like `flutter test` and `flutter analyze` are still unguarded, so prefer the tasks when you want the safety net.
- If the app is already running, stop it before a build or analyze run if things feel slow.

## Printable Cheat Sheet

For a wall-ready reference, see:

- [`developer_toolkit_cheat_sheet.png`](assets/developer_toolkit_cheat_sheet.png)

It matches the toolkit steps above and is sized for quick printing or lamination.

## Testing Guide

For the practical build-and-test recovery loop, see:

- [`testing_toolkit.md`](testing_toolkit.md)

Use that guide when `flutter run`, widget tests, or Windows builds start behaving strangely.
