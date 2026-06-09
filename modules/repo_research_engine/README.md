# New Earth Repo Research Engine

The Repo Research Engine is a safe, local-first research module for analysing Git repositories and turning them into structured knowledge, implementation ideas, Codex prompts, and Omega OS export bundles.

## What it does

- Scans local repositories without executing unknown code
- Builds a recursive inventory and repository tree
- Detects languages, frameworks, firmware, hardware design files, docs, licences, and dependencies
- Flags secrets, keys, tokens, certificates, suspicious binaries, and dangerous scripts
- Generates markdown reports and AI-ready knowledge notes
- Generates reusable Codex prompts
- Exports safe bundles into the New Earth Knowledge Vault structure
- Compares repositories and tracks file-level changes
- Exports dependency and architecture graph bundles

## Supported profiles

- MicroGrow
- New Earth Dashboard
- New Earth Living
- BioCalm
- New Earth Rehabilitation
- Omega OS
- Generic

## Main outputs

- `repo_inventory.json`
- `scan_manifest.json`
- `repository_tree.json`
- `analysis.json`
- `repo_research_report.md`
- `repo_summary.md`
- `security_report.md`
- `risk_report.md`
- `knowledge_report.md`
- `implementation_opportunities.md`
- `learning_notes.md`
- `repo_comparison.md`
- `change_tracking.md`
- `report_template_selection.md`
- `report_search_index.md`
- `release_notes.md`
- `bundle_delta_summary.md`
- `dependency_graph.md`
- `architecture_graph.md`
- `generated_prompts/*.md`

## Safe usage

The module is analysis-only.

It must never:

- run code from the target repository
- install dependencies from the target repository
- flash firmware
- contact external services
- export secrets in raw form

## Run it

```bash
python modules/repo_research_engine/scripts/run_research.py --repo "D:/path/to/repo" --profile MicroGrow --out modules/repo_research_engine/reports
```

To export into Omega OS at the same time:

```bash
python modules/repo_research_engine/scripts/run_research.py --repo "D:/path/to/repo" --profile MicroGrow --out modules/repo_research_engine/reports --omega-root "D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING/GIT_RESEARCH_LIBRARY"
```

## Module docs

- `docs/architecture.md`
- `docs/data_flow.md`
- `docs/security_model.md`
- `docs/roadmap.md`
