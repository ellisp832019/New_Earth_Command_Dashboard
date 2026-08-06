#!/usr/bin/env python3
"""
New Earth Project Repo Bridge - Dashboard Migration

Reads existing Dashboard project/task JSON if available, maps them to repo snapshots,
and writes unified project records.

Safe by default: does not overwrite existing Dashboard data.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List

MODULE_ROOT = Path(__file__).resolve().parents[1]
DASHBOARD_ROOT = MODULE_ROOT.parents[1]
SOURCES_CONFIG = MODULE_ROOT / "config" / "dashboard_sources.example.json"
REPO_REGISTRY = MODULE_ROOT / "config" / "repo_registry.example.json"
PROJECT_REPO_MAP = MODULE_ROOT / "config" / "project_repo_map.example.json"
SNAPSHOT_DIR = MODULE_ROOT / "data" / "repo_snapshots"
UNIFIED_DIR = MODULE_ROOT / "data" / "unified"


def read_json(path: Path, fallback: Any) -> Any:
    try:
        if path.exists():
            return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"Warning: could not read {path}: {exc}")
    return fallback


def normalize_projects(raw: Any) -> List[Dict[str, Any]]:
    if isinstance(raw, dict):
        if "projects" in raw:
            raw = raw["projects"]
        else:
            raw = list(raw.values())
    if not isinstance(raw, list):
        return []
    result = []
    for p in raw:
        if not isinstance(p, dict):
            continue
        project_id = str(p.get("id") or p.get("projectId") or p.get("slug") or p.get("name") or p.get("title") or "unknown").lower().replace(" ", "_")
        result.append({
            "id": project_id,
            "name": p.get("name") or p.get("title") or project_id,
            "status": p.get("status", "unknown"),
            "description": p.get("description", ""),
            "raw": p,
        })
    return result


def normalize_tasks(raw: Any) -> List[Dict[str, Any]]:
    if isinstance(raw, dict):
        if "tasks" in raw:
            raw = raw["tasks"]
        else:
            raw = list(raw.values())
    if not isinstance(raw, list):
        return []
    result = []
    for t in raw:
        if not isinstance(t, dict):
            continue
        result.append({
            "id": t.get("id") or t.get("taskId") or t.get("title") or "unknown_task",
            "title": t.get("title") or t.get("name") or "Untitled task",
            "status": t.get("status", "unknown"),
            "projectId": t.get("projectId") or t.get("project_id") or t.get("project") or t.get("parentProjectId"),
            "priority": t.get("priority"),
            "raw": t,
        })
    return result


def load_repo_snapshot(repo_id: str) -> Dict[str, Any]:
    return read_json(SNAPSHOT_DIR / f"{repo_id}_latest.json", {})


def main() -> None:
    sources = read_json(SOURCES_CONFIG, {})
    registry = read_json(REPO_REGISTRY, {"repos": []})
    mapping = read_json(PROJECT_REPO_MAP, {"mappings": []})

    projects_path = DASHBOARD_ROOT / sources.get("projects_source", "src/data/projects.json")
    tasks_path = DASHBOARD_ROOT / sources.get("tasks_source", "src/data/tasks.json")

    dashboard_projects = normalize_projects(read_json(projects_path, {"projects": []}))
    dashboard_tasks = normalize_tasks(read_json(tasks_path, {"tasks": []}))

    repo_by_id = {repo.get("id"): repo for repo in registry.get("repos", [])}
    repo_id_by_project_id = {m.get("dashboard_project_id"): m.get("repo_id") for m in mapping.get("mappings", [])}

    # Include mapped registry projects even if Dashboard JSON is not available yet.
    known_project_ids = {p["id"] for p in dashboard_projects}
    for repo in registry.get("repos", []):
        dp_id = repo.get("dashboard_project_id")
        if dp_id and dp_id not in known_project_ids:
            dashboard_projects.append({
                "id": dp_id,
                "name": repo.get("name", dp_id),
                "status": repo.get("status", "active"),
                "description": repo.get("current_phase", ""),
                "raw": {"source": "repo_registry"},
            })

    unified = []
    for project in dashboard_projects:
        project_id = project["id"]
        repo_id = repo_id_by_project_id.get(project_id)
        repo = repo_by_id.get(repo_id, {}) if repo_id else {}
        snapshot = load_repo_snapshot(repo_id) if repo_id else {}
        project_tasks = [t for t in dashboard_tasks if str(t.get("projectId")) == str(project_id)]

        next_actions = []
        if project_tasks:
            open_tasks = [t for t in project_tasks if str(t.get("status", "")).lower() not in {"done", "complete", "completed"}]
            next_actions.extend([t["title"] for t in open_tasks[:5]])
        if snapshot.get("dirty_files"):
            next_actions.append("Review uncommitted repo changes and decide whether to commit or document them.")
        if snapshot.get("todo_markers"):
            next_actions.append("Review TODO/NEXT markers and convert the useful ones into Dashboard tasks.")
        if repo and not snapshot:
            next_actions.append("Run scan_repos.py so repo status can be merged into this project.")

        unified.append({
            "projectId": project_id,
            "name": project.get("name", project_id),
            "dashboardStatus": project.get("status", "unknown"),
            "dashboardDescription": project.get("description", ""),
            "dashboardTasks": project_tasks,
            "repoLinked": bool(repo_id),
            "repoId": repo_id,
            "repoPath": repo.get("repo_path"),
            "omegaPath": repo.get("omega_path"),
            "currentPhase": repo.get("current_phase") or project.get("description"),
            "latestRepoStatus": snapshot,
            "nextActions": next_actions,
            "codexHandoffReady": bool(repo_id),
            "lastMergedAt": datetime.now(timezone.utc).isoformat(),
        })

    UNIFIED_DIR.mkdir(parents=True, exist_ok=True)
    output = UNIFIED_DIR / "unified_projects.json"
    output.write_text(json.dumps({"merged_at": datetime.now(timezone.utc).isoformat(), "projects": unified}, indent=2), encoding="utf-8")
    print(f"Wrote unified projects: {output}")
    print(f"Projects merged: {len(unified)}")

if __name__ == "__main__":
    main()
