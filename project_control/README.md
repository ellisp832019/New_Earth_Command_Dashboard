# Project Control

Canonical repository-control records for the New Earth Command Dashboard.

## File Roles

- Canonical YAML files in this directory are human-reviewed source records.
- Files in `generated/` are machine-generated and must not be edited manually.
- JSON Schema files in `schemas/` describe the expected structure of the canonical files.

## Read-Only Rule

The Project Control CLI is read-only with respect to application source code,
tests and canonical records. It writes only generated reports under
`project_control/generated` unless a future explicitly reviewed command states
otherwise.

## Canonical Files

- `status_definitions.yaml`
- `platform_manifest.yaml`
- `module_registry.yaml`
- `dependency_map.yaml`
- `risk_register.yaml`
- `verification_registry.yaml`
- `release_registry.yaml`
- `architecture_boundaries.yaml`
