# Codex Workflow

## Current Rule

Work from `TASK.md` and the relevant FSD files before coding.

## Local Verification

After changing Flutter code, run:

```powershell
flutter analyze
```

For app-shell or widget changes, also run:

```powershell
flutter test
```

Keep each task small and reviewable. Do not add database logic, AI features, cloud sync, or external integrations unless the current task explicitly asks for them.

## Build Strategy

Use `docs/developer_guide/build_strategy.md` as the short practical map from the full FSD set into build order.

## Development Log

Record completed build slices in `docs/developer_guide/development_log.md` after each meaningful implementation step.
