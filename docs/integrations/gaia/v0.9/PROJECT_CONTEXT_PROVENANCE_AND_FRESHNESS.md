# Project Context Provenance And Freshness

## Provenance Classes

1. `Observed live state`
2. `Recorded canonical state`
3. `Generated derived state`
4. `Historical evidence`

## Freshness Rules

- `Observed live state` expires as soon as the underlying Git or GitHub state changes.
- `Recorded canonical state` remains current until a human-reviewed update changes it.
- `Generated derived state` is valid only for the exact input commit, branch, and scan run that produced it.
- `Historical evidence` never becomes current again; it is retained as provenance.

## Recommended Labels

- `live`
- `checkpoint`
- `derived`
- `historical`
- `stale`
- `unknown`

## Behaviour Rules

- If a live value conflicts with a recorded checkpoint, report both.
- If freshness cannot be established, mark the field `unknown` or `stale`.
- Never silently replace a live observation with a checkpoint value.
- Never present a derived scan as if it were live state.

## Evidence References

Use repository-relative references whenever possible:

- `project_control/platform_manifest.yaml`
- `project_control/verification_registry.yaml`
- `project_control/risk_register.yaml`
- `project_control/generated/current_state.json`
- `docs/project_control/evidence/2026-08-07/...`

When GitHub evidence is included, cite:

- repository
- PR number
- head SHA
- workflow run id
- check name

## Live vs Recorded Example

If Project Control records branch `X` but `git rev-parse HEAD` returns branch `Y`, GAIA should say:

`Project Control records X, but live Git currently shows Y.`
