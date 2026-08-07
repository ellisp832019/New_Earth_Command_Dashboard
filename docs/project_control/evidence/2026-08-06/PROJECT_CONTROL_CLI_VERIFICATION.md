# Project Control CLI Verification

Date: 2026-08-06

## Commands And Results

- `dart run tool/project_control.dart doctor` -> exit `0`
- `dart run tool/project_control.dart scan` -> exit `0`
- `dart run tool/project_control.dart validate` -> exit `0`
- `dart run tool/project_control.dart report` -> exit `0`
- `dart run tool/project_control.dart diff` -> exit `0`
- `dart run tool/project_control.dart release-readiness` -> exit `1`

## Notes

- `doctor` reported the repository root, current branch and current commit.
- `scan` generated the current-state, module-matrix and repository-health reports.
- `release-readiness` is blocked by the open P0 risk and open P1 risks recorded in the canonical risk register.
