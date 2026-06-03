# User Guide: New Earth Project Repo Bridge

## What this module does

This module lets the New Earth Dashboard read its existing projects and tasks, connect them to your local VS Code repos, and create a merged project intelligence layer.

## Import location

Copy this folder into your Dashboard repo:

```text
modules/project_repo_bridge/
```

## Step 1: Let Codex inspect the Dashboard

Use:

```text
Inspect this Dashboard repo and report where projects and tasks are currently stored. Do not change files yet.
```

This tells you where the current Dashboard data lives.

## Step 2: Create real config files

Copy:

```text
config/repo_registry.example.json → config/repo_registry.json
config/project_repo_map.example.json → config/project_repo_map.json
config/dashboard_sources.example.json → config/dashboard_sources.json
```

Then edit paths to match your machine.

## Step 3: Scan repos

```bash
python modules/project_repo_bridge/scripts/scan_repos.py --config modules/project_repo_bridge/config/repo_registry.json
```

This creates:

```text
data/repo_snapshots/
data/progress_logs/
codex/CODEX_HANDOFF_*.md
```

## Step 4: Merge Dashboard projects/tasks with repo data

```bash
python modules/project_repo_bridge/scripts/migrate_dashboard_projects.py
```

This creates:

```text
data/unified/unified_projects.json
```

## Step 5: Add Dashboard UI

Add a new page/tab:

```text
Projects Intelligence
```

Use the UI components in:

```text
ui/ProjectIntelligencePage.tsx
ui/ProjectRepoCard.tsx
```

## Step 6: Export to Omega OS

Once the unified records look right:

```bash
python modules/project_repo_bridge/scripts/export_to_omega.py
```

This exports progress logs and snapshots to each configured Omega OS folder.

## Safety rules

- Do not delete existing Dashboard project/task data.
- Keep the first version read-only.
- Only make the unified record the source of truth once you have tested it.
- Back up your Dashboard repo before deeper integration.

## Recommended daily workflow

```text
1. Work in VS Code.
2. Commit or save work.
3. Run scan_repos.py.
4. Run migrate_dashboard_projects.py.
5. Open Dashboard → Projects Intelligence.
6. Export to Omega OS when ready.
7. Use generated Codex handoff for the next build step.
```
