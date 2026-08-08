# GAIA v0.9 Slice D Contract Representability Review

Date: 2026-08-08

## Scope

This review checks whether Project Context contract v1 can truthfully represent the Dashboard-side Slice B + Slice C states needed for the provenance, freshness, and data-quality assembler.

## Conclusion

`CONTRACT REPRESENTABILITY: REQUIRES MINIMAL CORRECTION`

The required correction is backward-compatible:

- `repository.observedBranch` is now optional in v1 snapshots so detached HEAD can be represented without inventing a branch name.

No contract version bump is required.

## Findings

### Detached HEAD

Before the correction, `repository.observedBranch` was required in the schema and parser, but Slice C correctly models detached HEAD with a null observed branch.

After the correction:

- live branch names are preserved when present
- detached HEAD snapshots omit `repository.observedBranch`
- no placeholder branch name is invented

### GitHub-offline mode

This state is representable without a contract break because:

- `ci.requiredChecks` can be supplied explicitly from approved metadata
- `ci.runs` can be an empty list when no GitHub runs are available
- `dataQuality` can record the missing or stale evidence honestly

### CI-unavailable mode

This state is representable without a contract break because:

- the snapshot can still be assembled from live Git plus recorded Project Control evidence
- CI evidence can be omitted from `ci.runs`
- freshness and data-quality fields can explain the missing CI evidence

### Protected-branch-unavailable mode

This state is representable with explicit approved metadata for the protected branch record.

The assembler does not need to fabricate GitHub state, and the contract shape does not need to change for this slice.

### Missing remote identity

The live Git adapter may fail to observe a remote identity, but the assembler can still remain truthful by using approved explicit metadata for the repository remote identity field.

No contract change is required for this slice.

## Cross-Checks

- Slice A models and parser: inspected
- Slice B Project Control bundle: inspected
- Slice C local Git live state: inspected
- offline behaviour doc: inspected
- field ownership doc: inspected
- provenance and freshness doc: inspected
- data quality doc: inspected

## Resulting Contract Rule

`repository.observedBranch` is optional for detached HEAD only.

All other required v1 fields remain required.
