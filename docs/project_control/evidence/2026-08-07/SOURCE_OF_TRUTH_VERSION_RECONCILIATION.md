# Source Of Truth Version Reconciliation

- Date: 2026-08-07
- Branch: `reconcile/dashboard-source-of-truth-version-policy-2026-08-07`
- Latest head SHA: `26bbb9c717ac3c752bc0ea9723a6874aecd3326d`

## What Was Reconciled

- The user-facing README status line was updated from the stale `V0.1 foundation is live` wording to `Beta baseline is live`.
- The live project-control manifest now records the active reconciliation branch and commit.

## Canonical Version Sources

- `pubspec.yaml` remains the package version authority at `1.0.0+1`.
- `lib/core/constants/app_build_info.dart` remains aligned to `1.0.0+1`.
- `project_control/platform_manifest.yaml` mirrors the active repository state and the same application version.
- `project_control/release_registry.yaml` remains a historical record for the prior verified baseline and was not rewritten.

## Drift Review

- Historical evidence under `docs/project_control/evidence/2026-08-06/` was left intact.
- Generated outputs under `project_control/generated/` were not edited manually.
- No source code version bump was required for this reconciliation because the application version was already consistent.

## Closeout Note

- This reconciliation makes the live README and project-control metadata agree with the current branch state while preserving historical verification records.
