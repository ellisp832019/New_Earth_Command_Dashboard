# How To Use Project Control

1. Review the canonical YAML records.
2. Run `dart run tool/project_control.dart doctor`.
3. Run `dart run tool/project_control.dart scan`.
4. Run `dart run tool/project_control.dart validate`.
5. Run `dart run tool/project_control.dart report`.
6. Run `dart run tool/project_control.dart release-readiness`.

The CLI is read-only with respect to application source code, tests and
canonical records. It writes only generated reports under
`project_control/generated` unless a future explicitly reviewed command states
otherwise.
