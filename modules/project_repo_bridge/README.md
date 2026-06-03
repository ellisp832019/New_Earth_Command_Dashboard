# New Earth Project Repo Bridge

A local-first Dashboard module that bridges existing Dashboard projects/tasks with local VS Code/Git repositories and Omega OS project records.

## Purpose

This module lets the New Earth Dashboard look at its current projects and tasks, connect them to local repos, scan repo progress, and generate a unified project intelligence layer.

It is designed to be safe at first:

- Read-only by default
- Does not overwrite existing Dashboard projects/tasks
- Uses adapters so it can fit your current Dashboard structure
- Keeps paths configurable
- Works locally without cloud services

## What it creates

- Unified project records
- Repo snapshots
- Markdown progress logs
- Codex handoff files
- Omega OS export-ready records
- Dashboard UI components for a Projects Intelligence page

## Folder

Import this folder into your Dashboard repo:

```text
modules/project_repo_bridge/
```

## First command

From your Dashboard repo root:

```bash
python modules/project_repo_bridge/scripts/scan_repos.py --config modules/project_repo_bridge/config/repo_registry.example.json
```

Then run:

```bash
python modules/project_repo_bridge/scripts/migrate_dashboard_projects.py
```

## Important

Before wiring this into the real Dashboard UI, ask Codex to inspect the Dashboard repo and identify where projects and tasks currently live.

Use:

```text
Inspect this Dashboard repo and report where projects and tasks are currently stored. Do not change files yet. Return the safest adapter points for the Project Repo Bridge.
```
