# Generated Code Policy

This repository uses committed generated source.

## Policy

- Generated files are kept in Git.
- CI regenerates code and fails if the working tree drifts from the committed outputs.
- We do not rely on a mixed policy where some generated outputs are committed and others are ignored.

## Committed Generated Paths

- `lib/core/database/app_database.g.dart`
- `lib/features/omega_engineering_studio/data/engineering_database.g.dart`
- `project_control/generated/*`

## Regeneration Commands

- `dart run build_runner build --delete-conflicting-outputs`
- `dart run tool/project_control.dart scan`

## What CI Must Do

- regenerate before analyze/test/build where needed
- fail if the regenerated tree differs from the committed tree
- avoid committing anything automatically from the workflow

## Why This Policy Exists

- It keeps desktop builds reproducible.
- It makes project-control evidence reviewable in code review.
- It prevents hidden drift between the source models and the generated outputs.
