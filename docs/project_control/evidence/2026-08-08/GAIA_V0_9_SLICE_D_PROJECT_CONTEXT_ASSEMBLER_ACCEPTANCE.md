# GAIA v0.9 Slice D Project Context Assembler Acceptance

Date: 2026-08-08

## Prompt Target

- New Earth Command Dashboard
- Slice: GAIA v0.9 Dashboard Implementation Slice D
- Scope: Project Context provenance, freshness, data-quality, and snapshot assembler

## Branch And Baseline

- Starting protected main SHA: `0bdc51a90996568a9e22175a62547c095c3c809f`
- Slice D branch: `feature/gaia-v0.9-project-context-assembler-2026-08-08`
- Current worktree branch: `feature/gaia-v0.9-project-context-assembler-2026-08-08`
- Current PR head SHA: `a048867826b09412acc55f90ef3f7d9e66b83641`

## Contract Representability

- Result: `REQUIRES MINIMAL CORRECTION`
- Correction applied: `repository.observedBranch` is optional in Project Context v1 so detached HEAD can be represented without inventing a branch name.
- Contract version remains `v1`.

## Assembly Boundary

- Assembler location: `lib/features/gaia/domain/project_context_assembler.dart`
- Assembler type: pure deterministic snapshot assembler
- Input type: `ProjectContextAssemblyInput`
- Output type: `ProjectContextSnapshot`
- No filesystem I/O in assembler: `YES`
- No Git execution in assembler: `YES`
- No GitHub access in assembler: `YES`
- No GAIA backend access in assembler: `YES`
- No UI work in assembler: `YES`

## Assembly Inputs

- `ProjectControlContextBundle`
- `LocalGitLiveState`
- Explicit assembly metadata:
  - snapshot id
  - generation timestamp
  - repository identity
  - default branch
  - approved remote identity
  - protected branch commit
  - required CI checks
  - CI runs
  - dashboard version
  - dashboard maturity
  - GAIA integration version
  - GAIA dependency ref
  - baseline metadata
  - source allowlist
  - evidence references

## Provenance Model

- Observed live state remains distinct from recorded canonical state.
- Derived Project Control evidence remains labelled as derived or historical.
- Historical evidence is preserved as provenance and is not promoted to live truth.

## Freshness Model

- Live Git observations are current only for the observed repository state.
- Recorded Project Control data is treated as checkpoint data.
- Generated evidence is valid only for the input commit / scan inputs that produced it.
- Historical verification remains historical even when it is still useful.

## Data-Quality Model

- Implemented states: `good`, `degraded`, `stale`, `conflicting`, `missing`
- Quality precedence:
  1. `missing`
  2. `conflicting`
  3. `stale`
  4. `degraded`
  5. `good`
- Missing and stale fields are surfaced explicitly.
- Live-versus-recorded drift is surfaced explicitly.
- Empty or unavailable CI evidence is labelled honestly.

## Snapshot ID Policy

- Snapshot IDs are supplied explicitly through assembly metadata.
- The assembler does not synthesize snapshot IDs from hidden state.

## Clock Policy

- The generation timestamp is injected explicitly through assembly metadata.
- The assembler does not read the wall clock itself.

## Offline Policy

- GitHub-offline operation remains representable.
- Local Git state is still observable.
- Recorded Project Control data remains readable.
- The assembler returns a degraded or missing quality state instead of guessing.

## Detached HEAD Policy

- Detached HEAD is represented by omitting `repository.observedBranch`.
- No placeholder branch name is invented.
- The data-quality record surfaces the missing live branch name explicitly.

## No-Upstream Policy

- When a branch has no configured upstream, ahead/behind data is omitted.
- The data-quality record surfaces the missing ahead/behind information explicitly.

## GitHub-Unavailable Policy

- CI runs can be empty when GitHub evidence is unavailable.
- Required checks are supplied explicitly through metadata when available.
- The snapshot remains read-only and deterministic.

## Live Vs Checkpoint Policy

- Live Git observations are preserved as live.
- Project Control checkpoint values remain checkpoint values.
- Conflicts and stale fields are surfaced rather than overwritten.

## Generated Stale-Data Policy

- Generated current-state and repository-health values are treated as derived evidence.
- If those values differ from the live observation, the snapshot records them as stale.

## Verification Applicability Policy

- Verification records are preserved as historical evidence.
- Stale verification commits are surfaced explicitly when they do not match live Git.

## Source Allowlist

- `git status`
- `git rev-parse HEAD`
- `git branch --show-current`
- `project_control/*.yaml`

## Evidence References

- `docs/project_control/evidence/2026-08-08/GAIA_V0_9_SLICE_D_CONTRACT_REPRESENTABILITY_REVIEW.md`
- `docs/project_control/evidence/2026-08-08/GAIA_V0_9_SLICE_D_PROJECT_CONTEXT_ASSEMBLER_ACCEPTANCE.md`

## Validation

- `dart format --output=none --set-exit-if-changed lib test tool`
- `flutter analyze`
- `flutter test`
- `dart run tool/project_control.dart validate`
- `flutter build windows --release`
- Windows smoke launch: passed for a 10-second hidden launch window
- Windows release executable:
  - `build/windows/x64/runner/Release/new_earth_command_dashboard.exe`
- Windows release SHA-256:
  - `6976962B67AD57E7B0E3AA3D16531556617F05AAE7C5BC032FAA06CA8C9B331E`

## Exact-Head CI

- PR: `#16`
- Flutter Quality: `pass`
  - Run ID: `31257513419`
- Project Control Validation: `pass`
  - Run ID: `31257513418`
- Windows Release Build: `pass`
  - Run ID: `31257513415`

## Targeted Tests

- `test/features/gaia/project_context/project_context_assembler_test.dart`
- `test/features/gaia/project_context/project_context_snapshot_test.dart`

## Full Flutter Suite

- Passed

## Project Control

- Validation passed
- No canonical `project_control/*.yaml` files were modified

## External Repository

- `New-Earth-AI-Employee` untouched

## R-002 Recommendation

- Keep `R-002` as `mitigating` until the live-versus-recorded evidence has been reviewed on the pushed PR head.

## Known Limitations

- The assembler currently records the minimum required provenance and freshness semantics for this slice; response composition remains a future slice.

## Slice E Readiness

- The assembler boundary is in place.
- Slice E can be evaluated after the exact-head CI runs are recorded.
