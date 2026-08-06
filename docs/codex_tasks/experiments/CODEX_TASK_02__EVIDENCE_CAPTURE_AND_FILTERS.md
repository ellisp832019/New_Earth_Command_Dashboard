# Codex Task 02 - Evidence Capture and Filters

## Goal

Make experiment evidence easier to review by surfacing evidence types, counts, filters, and missing-proof cues in the workspace.

## Requirements

- Show evidence-ready and needs-evidence counts in the workspace.
- Infer evidence types from attached evidence entries.
- Add filter chips for evidence-ready, needs-evidence, and common evidence types.
- Surface evidence types on experiment cards.
- Show a compact evidence review block in the detail panel.
- Keep the feature local-first and review-first.

## Suggested UI changes

- Add `Needs evidence` chips where proof is missing.
- Add `Evidence ready` summary metrics in the hero and registry.
- Add evidence type chips such as `Notes`, `Data`, `Logs`, `Images`, and `Screenshots`.
- Keep the filters single-select and calm.

## Acceptance Criteria

- The user can quickly see which experiments need more proof.
- The user can filter the workspace by evidence state or evidence type.
- The detail panel shows evidence in a more useful format than a raw text dump.
- The app still analyzes cleanly after the change.

