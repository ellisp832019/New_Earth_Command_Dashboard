# Module Structure

## Flutter feature layout

- `lib/features/omega_engineering_studio/domain/`
- `lib/features/omega_engineering_studio/data/`
- `lib/features/omega_engineering_studio/application/`
- `lib/features/omega_engineering_studio/presentation/`
- `lib/features/omega_engineering_studio/presentation/widgets/`

## Responsibilities

- Domain: entities, enums, snapshot models, and small pure helpers.
- Data: local mock repository and future persistence boundary.
- Application: filtering, search, readiness, and summary services.
- Presentation: dashboard, workspace sections, loading, error, and empty states.

## Runtime expectations

- Offline-first.
- Mock data first.
- Integration-ready hooks only.
- Calm engineering UI with reusable cards and chips.
