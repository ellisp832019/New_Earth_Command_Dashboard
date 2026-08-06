# Documentation Audit

This audit highlights the main documentation strengths, overlaps, and cleanup opportunities in the repo.

## What Is Good

- The docs are layered well:
  - FSD
  - roadmap
  - architecture
  - user guides
  - developer guides
  - task docs
- The repo now has several clean index pages:
  - `README.md`
  - `docs/README.md`
  - `docs/roadmap/README.md`
  - `PROJECT_INDEX.md`
- The roadmap docs are now clearer about:
  - what is built
  - what is active
  - what is parked

## Overlaps To Watch

### 1. Root README vs docs README

Both files act as entry points.

This is not wrong, but it means:
- root README should stay product-facing
- docs README should stay documentation-facing
- the new `PROJECT_INDEX.md` should become the neutral master index

### 2. Multiple Roadmap Summaries

These docs overlap in scope:
- `docs/roadmap/project_now_next_later.md`
- `docs/roadmap/built_vs_planned_checklist.md`
- `docs/roadmap/release_readiness_summary.md`
- `docs/roadmap/subsystem_status_audit.md`
- `docs/roadmap/future_architecture_map.md`

They are useful, but they all summarize the same project from different angles.

Recommendation:
- keep them all
- make each one distinct
- use `docs/roadmap/README.md` as the gateway

### 3. Module Hub Documentation Pair

These two files overlap by design:
- `docs/architecture/module_hub/README.md`
- `docs/architecture/module_hub/module_hub_architecture.md`

Recommendation:
- keep the README as the short reference entry
- keep the architecture file as the detailed build reference

### 4. Repository Intelligence / Obsidian Sync Docs

The bridge module now has many docs and templates.

That is good for reuse, but there is some duplication between:
- README
- install checklist
- codex prompt
- dashboard integration doc
- schema examples
- template profiles

Recommendation:
- treat the README as the human quick start
- treat the checklist as the setup path
- treat the schema and templates as reusable reference material

## Stale-Or-Risky Areas

### Root README Naming

The root README now uses `New Earth Command Dashboard`, which matches the current repo framing.

Recommendation:
- keep the naming consistent across future docs and screenshots

### Some Specialized Docs May Reflect Older Slice Language

Several docs in:
- `docs/codex_tasks/`
- `docs/tasks/`
- `docs/fsd/`
- `modules/`

may still describe slices that are already complete or partially superseded.

Recommendation:
- use the audit view when deciding whether a task doc is still active
- keep historical docs, but mark them clearly as complete if the work is done

### Generated Or Artifact Files

There are also non-primary documentation artifacts in the repo such as:
- PDFs
- HTML test documents
- preserved build proof images

Recommendation:
- keep them as assets
- avoid treating them as the primary source of truth

## Best Current Doc Hierarchy

1. `PROJECT_INDEX.md`
2. `README.md`
3. `docs/README.md`
4. `docs/fsd/00_master_index.md`
5. `docs/roadmap/README.md`
6. `TASK.md`

## Bottom Line

The documentation is strong, but it is now large enough that the main job is curation:

- keep the index pages clean
- keep each roadmap page distinct
- mark historical task docs clearly
- align naming across the root README and the current product identity
