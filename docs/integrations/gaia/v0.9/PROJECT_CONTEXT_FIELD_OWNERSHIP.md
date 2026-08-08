# Project Context Field Ownership

## Ownership Matrix

| Field | Meaning | Owning source | Fallback source | Live observation required | Freshness policy | Historical values permitted | GAIA may derive | Evidence format |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `platform.applicationVersion` | Dashboard package version | `pubspec.yaml` | `lib/core/constants/app_build_info.dart` | No | Until version changes | Yes | No | file path + version |
| `platform.maturity` | Product maturity | `project_control/platform_manifest.yaml` | `README.md` if needed for human context | No | Until reviewed | Yes | No | file path + record date |
| `repository.observedBranch` | Live branch name; omitted for detached HEAD | `git branch --show-current` | none | Yes | Immediate | No | Yes | git ref + commit |
| `repository.observedCommit` | Live HEAD SHA | `git rev-parse HEAD` | none | Yes | Immediate | No | Yes | git SHA |
| `repository.defaultBranch` | Protected default branch | GitHub branch metadata | local branch config | Yes when GitHub is available | Immediate | Yes | No | GitHub ref |
| `baseline.tagName` | Controlled checkpoint tag | Git tag `dashboard-controlled-baseline-2026-08-07` | none | No | Until retagged, which should not happen | Yes | No | git tag + target SHA |
| `baseline.tagTarget` | Historical baseline commit | Git tag target | none | No | Immutable after tag creation | Yes | No | git tag object + commit |
| `baseline.recordedCommit` | Recorded checkpoint commit | `project_control/platform_manifest.yaml` | evidence docs | No | Until updated by human review | Yes | Yes | manifest + evidence |
| `repository.dirtyState` | Working tree cleanliness | `git status --short` | none | Yes | Immediate | No | Yes | git status output |
| `repository.aheadBehind` | Divergence from remote | `git rev-list --left-right` or GitHub compare | none | Yes when available | Immediate | No | Yes | git comparison |
| `releaseReadiness.status` | Readiness signal | `project_control/generated/release_readiness.json` and canonical registries | evidence docs | No | Valid for the exact scan inputs | Yes | Yes | generated report + commit |
| `repositoryHealth.status` | Health summary | `project_control/generated/repository_health.json` | none | No | Valid for the exact scan inputs | Yes | Yes | generated report + scan id |
| `risks.items` | Canonical risk register | `project_control/risk_register.yaml` | evidence docs | No | Until registry review | Yes | Yes | risk id + evidence |
| `modules.items` | Canonical module registry | `project_control/module_registry.yaml` | scan output | No | Until registry review | Yes | Yes | module id + verification |
| `verification.items` | Verification history | `project_control/verification_registry.yaml` | evidence docs | No | Until new verification is added | Yes | Yes | verification id + run id |
| `ci.requiredChecks` | GitHub-required CI evidence | GitHub Actions runs and PR checks | local validation notes | Yes for current PRs | Immediate for exact head | Historical runs retained | Yes | run id + SHA |
| `provenance.evidence` | Evidence trail | docs under `docs/project_control/evidence/` | none | No | Historical and append-only | Yes | Yes | relative evidence path |
| `gaia.integrationVersion` | Dashboard-to-GAIA contract version | pinned package ref and package version | package lockfile | No | Until package ref changes | Yes | No | package ref + package version |

## Notes

- Live Git state must come from observation, not from a stale manifest.
- Project Control checkpoint fields may be authoritative for the checkpoint they describe, but not for the current live branch after later merges.
- Generated files are derived outputs only and never override canonical records.
