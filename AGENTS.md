# AGENTS.md — New Earth Command Dashboard

## Project

New Earth Command Dashboard is a local-first Flutter app for managing New Earth projects, tasks, daily focus, learning, content, business actions, wellbeing, and build progress.

## Source Documents

Before coding, read:

- `docs/fsd/00_master_index.md`
- The FSD file relevant to the current task
- `TASK.md`

## Core Rule

Do not build the whole app at once.

Only implement the current task in `TASK.md`.

## Architecture Rules

- Use Flutter and Dart.
- Use Material 3.
- Use a feature-based folder structure.
- Use `go_router` for routing.
- Use Riverpod for state management when state is needed.
- Use Drift and SQLite when database work begins.
- Keep UI separate from data logic.
- Keep files clean, simple, and readable.

## MVP Rules

- Local-first.
- Offline-first.
- No login for V0.1.
- No cloud sync for V0.1.
- No AI assistant for V0.1.
- No calendar, GitHub, WordPress, or MicroGrow live integration yet.

## UX Rules

- Clarity first. Complexity later.
- Dashboard must reduce overwhelm.
- Use the Top 3 task rule.
- Use calm New Earth wording.
- Prefer “Parked” or “Carry Forward” over failure/shame language.
- Keep screens simple and focused.

## Safety Rules

- Do not delete existing files unless clearly required.
- Prefer small, reviewable changes.
- After changes, run `flutter analyze` if possible.
- Report what changed.
- Report any errors honestly.