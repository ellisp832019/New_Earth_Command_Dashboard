# Release Readiness Baseline

Date: 2026-08-06

## Result

- `blocked`

## Reasons

- An open P0 risk exists.
- One or more open P1 risks remain.

## Current Evidence

- `dart run tool/project_control.dart release-readiness` exited with code `1`.
- The generated readiness report was written to `project_control/generated/release_readiness.json`.

## Interpretation

The repository is healthy enough to continue controlled hardening work, but it is not ready for a readiness-positive release decision while the open P0 and P1 risks remain.
