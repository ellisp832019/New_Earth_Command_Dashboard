# FSD: New Earth Project Repo Bridge

## 1. Overview

The New Earth Project Repo Bridge connects Dashboard project/task data with local VS Code/Git repositories and Omega OS long-term project records.

The goal is to make the Dashboard a living command centre that can answer:

- What projects exist?
- What tasks are active?
- Which repos are linked?
- What changed recently?
- Which projects need documentation?
- Which projects need Codex handoff?
- What should be exported to Omega OS?

## 2. Core principles

1. Local-first.
2. Read-only migration first.
3. Do not delete or overwrite existing Dashboard data.
4. Use adapters to fit the current Dashboard structure.
5. Keep paths configurable.
6. Generate human-readable Markdown as well as JSON.
7. Support Codex handoff generation.

## 3. Inputs

### 3.1 Existing Dashboard data

Possible sources:

- `src/data/projects.ts`
- `src/data/tasks.ts`
- `src/features/projects/`
- `src/features/tasks/`
- local JSON files
- local database files
- localStorage-backed stores

### 3.2 Repo registry

`config/repo_registry.json`

Defines known repos, paths, project IDs and Omega OS paths.

### 3.3 Project repo map

`config/project_repo_map.json`

Maps current Dashboard project IDs to repo IDs.

## 4. Outputs

- `data/repo_snapshots/*.json`
- `data/progress_logs/*.md`
- `data/unified/unified_projects.json`
- `data/dashboard_cache/project_intelligence_cache.json`
- `omega_exports/*`
- `codex/CODEX_HANDOFF_*.md`

## 5. Unified Project Record

```json
{
  "projectId": "microgrow",
  "name": "MicroGrow",
  "dashboardStatus": "active",
  "dashboardTasks": [],
  "repoLinked": true,
  "repoId": "microgrow",
  "repoPath": "D:/PROJECTS/microgrow",
  "omegaPath": "D:/NEW_EARTH_OMEGA_OS_PACK/03_ACTIVE_PROJECTS/MicroGrow",
  "currentPhase": "PCB V0.1 preparation",
  "latestRepoStatus": {},
  "nextActions": [],
  "codexHandoffReady": true,
  "lastScannedAt": "2026-06-03T00:00:00Z"
}
```

## 6. Phase plan

### Phase 1: Discovery

Codex inspects the Dashboard repo and reports where projects/tasks are stored.

### Phase 2: Adapter wiring

Create adapters that read existing project/task data and normalize it.

### Phase 3: Repo scanning

Scan configured repos for Git status, latest commits, branch, tags, docs and TODO markers.

### Phase 4: Unified records

Merge Dashboard data and repo data into `unified_projects.json`.

### Phase 5: Dashboard UI

Add Projects Intelligence page using the unified records.

### Phase 6: Omega OS export

Export progress logs, snapshots and handoffs to Omega OS project folders.

## 7. Acceptance criteria

- Existing Dashboard project/task pages still work.
- The module can be imported without breaking the app.
- Repo registry can be edited manually.
- Scanner creates JSON snapshots.
- Migration creates unified project records.
- UI components can display merged project intelligence.
- Codex handoff files can be generated.
- Omega OS exports are path-configurable.
