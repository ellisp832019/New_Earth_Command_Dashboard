# Repo Research Engine Dashboard Pages

## Intended Pages

### Repo Research Home

- route: `/more/repo-research-engine`
- purpose: entry page, recent runs, quick actions, safe status

### Repository Scanner

- route: `/more/repo-research-engine/scanner`
- purpose: clone a source into a structured workspace, then select the local repo path and run the safe scan

### Research Reports

- route: `/more/repo-research-engine/reports`
- purpose: view inventory, summary, security, risk, and knowledge outputs

### Profile Manager

- route: `/more/repo-research-engine/profiles`
- purpose: load, inspect, and edit reusable JSON profiles

### Knowledge Vault Exports

- route: `/more/repo-research-engine/exports`
- purpose: preview Omega OS export targets and generated bundles

### Codex Prompt Generator

- route: `/more/repo-research-engine/prompts`
- purpose: generate task-specific prompts from the current analysis

### Settings

- route: `/more/repo-research-engine/settings`
- purpose: configure paths, export roots, and scan defaults

## UI Contract

- Every page stays local-first.
- No page may execute repository code.
- Any secret-like value must stay masked in the UI.
- Reports should favour clarity over density.

## Integration Status

The page map now matches the live Flutter route structure and is ready for further UI polish.
