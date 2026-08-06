#!/usr/bin/env python3
"""
New Earth Project Repo Bridge - Repo Scanner

Scans configured local Git repositories and writes JSON snapshots plus Markdown progress logs.
Read-only: this script does not modify source repos.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
from dataclasses import dataclass, asdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

MODULE_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG = MODULE_ROOT / "config" / "repo_registry.example.json"
SNAPSHOT_DIR = MODULE_ROOT / "data" / "repo_snapshots"
PROGRESS_DIR = MODULE_ROOT / "data" / "progress_logs"
CODEX_DIR = MODULE_ROOT / "codex"

TODO_MARKERS = ["TODO", "FIXME", "NEXT", "ROADMAP", "MILESTONE", "BUG", "HACK", "WIP"]
DOC_CANDIDATES = [
    "README.md",
    "CHANGELOG.md",
    "ROADMAP.md",
    "TODO.md",
    "docs",
    "FSD",
    "CODEX",
]

@dataclass
class RepoSnapshot:
    id: str
    name: str
    repo_path: str
    dashboard_project_id: Optional[str]
    omega_path: Optional[str]
    status: Optional[str]
    type: Optional[str]
    current_phase: Optional[str]
    exists: bool
    is_git_repo: bool
    branch: Optional[str]
    latest_commit: Optional[str]
    latest_commit_date: Optional[str]
    tags: List[str]
    dirty_files: List[str]
    recent_commits: List[str]
    docs_found: List[str]
    todo_markers: List[Dict[str, Any]]
    scan_warnings: List[str]
    scanned_at: str


def run_git(repo_path: Path, args: List[str]) -> Optional[str]:
    try:
        result = subprocess.run(
            ["git", *args],
            cwd=str(repo_path),
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=15,
            check=False,
        )
        if result.returncode != 0:
            return None
        return result.stdout.strip()
    except Exception:
        return None


def safe_read_text(path: Path, limit: int = 500_000) -> str:
    try:
        if path.stat().st_size > limit:
            return ""
        return path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def find_docs(repo_path: Path) -> List[str]:
    found: List[str] = []
    for candidate in DOC_CANDIDATES:
        for path in repo_path.glob(f"**/{candidate}*"):
            if any(part in {".git", "node_modules", "build", ".dart_tool", "dist", ".venv"} for part in path.parts):
                continue
            rel = path.relative_to(repo_path).as_posix()
            if rel not in found:
                found.append(rel)
            if len(found) >= 50:
                return found
    return found


def find_todo_markers(repo_path: Path) -> List[Dict[str, Any]]:
    results: List[Dict[str, Any]] = []
    allowed_ext = {".md", ".txt", ".ts", ".tsx", ".js", ".jsx", ".py", ".dart", ".cpp", ".c", ".h", ".ino", ".json", ".yaml", ".yml"}
    ignored_dirs = {".git", "node_modules", "build", ".dart_tool", "dist", ".venv", "__pycache__", ".next"}
    for path in repo_path.rglob("*"):
        if len(results) >= 200:
            break
        if path.is_dir() or path.suffix.lower() not in allowed_ext:
            continue
        if any(part in ignored_dirs for part in path.parts):
            continue
        text = safe_read_text(path)
        if not text:
            continue
        for idx, line in enumerate(text.splitlines(), start=1):
            upper = line.upper()
            if any(marker in upper for marker in TODO_MARKERS):
                results.append({
                    "file": path.relative_to(repo_path).as_posix(),
                    "line": idx,
                    "text": line.strip()[:240],
                })
                if len(results) >= 200:
                    break
    return results


def scan_repo(repo: Dict[str, Any]) -> RepoSnapshot:
    repo_path = Path(repo.get("repo_path", "")).expanduser()
    warnings: List[str] = []
    exists = repo_path.exists()
    is_git_repo = (repo_path / ".git").exists() if exists else False

    branch = latest_commit = latest_commit_date = None
    tags: List[str] = []
    dirty_files: List[str] = []
    recent_commits: List[str] = []
    docs_found: List[str] = []
    todo_markers: List[Dict[str, Any]] = []

    if not exists:
        warnings.append("Repo path does not exist on this machine.")
    elif not is_git_repo:
        warnings.append("Repo path exists but is not a Git repo.")
    else:
        branch = run_git(repo_path, ["branch", "--show-current"])
        latest_commit = run_git(repo_path, ["log", "-1", "--pretty=%h %s"])
        latest_commit_date = run_git(repo_path, ["log", "-1", "--pretty=%cI"])
        tags_raw = run_git(repo_path, ["tag", "--sort=-creatordate"])
        tags = tags_raw.splitlines()[:20] if tags_raw else []
        dirty_raw = run_git(repo_path, ["status", "--porcelain"])
        dirty_files = dirty_raw.splitlines() if dirty_raw else []
        commits_raw = run_git(repo_path, ["log", "--oneline", "--decorate", "-n", "30"])
        recent_commits = commits_raw.splitlines() if commits_raw else []
        docs_found = find_docs(repo_path)
        todo_markers = find_todo_markers(repo_path)

    return RepoSnapshot(
        id=repo.get("id", "unknown"),
        name=repo.get("name", repo.get("id", "Unknown")),
        repo_path=str(repo_path),
        dashboard_project_id=repo.get("dashboard_project_id"),
        omega_path=repo.get("omega_path"),
        status=repo.get("status"),
        type=repo.get("type"),
        current_phase=repo.get("current_phase"),
        exists=exists,
        is_git_repo=is_git_repo,
        branch=branch,
        latest_commit=latest_commit,
        latest_commit_date=latest_commit_date,
        tags=tags,
        dirty_files=dirty_files,
        recent_commits=recent_commits,
        docs_found=docs_found,
        todo_markers=todo_markers,
        scan_warnings=warnings,
        scanned_at=datetime.now(timezone.utc).isoformat(),
    )


def write_snapshot(snapshot: RepoSnapshot) -> Path:
    SNAPSHOT_DIR.mkdir(parents=True, exist_ok=True)
    path = SNAPSHOT_DIR / f"{snapshot.id}_latest.json"
    path.write_text(json.dumps(asdict(snapshot), indent=2), encoding="utf-8")
    dated = SNAPSHOT_DIR / f"{snapshot.id}_{datetime.now().strftime('%Y-%m-%d_%H%M%S')}.json"
    dated.write_text(json.dumps(asdict(snapshot), indent=2), encoding="utf-8")
    return path


def write_progress_log(snapshot: RepoSnapshot) -> Path:
    PROGRESS_DIR.mkdir(parents=True, exist_ok=True)
    path = PROGRESS_DIR / f"{snapshot.id}_progress.md"
    dirty_count = len(snapshot.dirty_files)
    todo_count = len(snapshot.todo_markers)
    docs_count = len(snapshot.docs_found)
    lines = [
        f"# {snapshot.name} Progress Log",
        "",
        f"Last scanned: {snapshot.scanned_at}",
        "",
        "## Current state",
        "",
        f"- Repo path: `{snapshot.repo_path}`",
        f"- Dashboard project ID: `{snapshot.dashboard_project_id}`",
        f"- Omega OS path: `{snapshot.omega_path}`",
        f"- Exists: `{snapshot.exists}`",
        f"- Git repo: `{snapshot.is_git_repo}`",
        f"- Branch: `{snapshot.branch}`",
        f"- Latest commit: `{snapshot.latest_commit}`",
        f"- Dirty files: `{dirty_count}`",
        f"- Docs found: `{docs_count}`",
        f"- TODO/NEXT markers found: `{todo_count}`",
        "",
        "## Current phase",
        "",
        snapshot.current_phase or "Not set yet.",
        "",
        "## Recent commits",
        "",
    ]
    lines.extend([f"- `{c}`" for c in snapshot.recent_commits[:15]] or ["- No commits found."])
    lines += ["", "## Dirty files", ""]
    lines.extend([f"- `{f}`" for f in snapshot.dirty_files[:50]] or ["- Working tree clean or unavailable."])
    lines += ["", "## Documentation found", ""]
    lines.extend([f"- `{d}`" for d in snapshot.docs_found[:50]] or ["- No key docs detected."])
    lines += ["", "## TODO / NEXT markers", ""]
    for item in snapshot.todo_markers[:50]:
        lines.append(f"- `{item['file']}:{item['line']}` — {item['text']}")
    if not snapshot.todo_markers:
        lines.append("- No TODO/NEXT markers found.")
    lines += ["", "## Scan warnings", ""]
    lines.extend([f"- {w}" for w in snapshot.scan_warnings] or ["- None."])
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return path


def write_codex_handoff(snapshot: RepoSnapshot) -> Path:
    CODEX_DIR.mkdir(parents=True, exist_ok=True)
    today = datetime.now().strftime("%Y-%m-%d")
    path = CODEX_DIR / f"CODEX_HANDOFF_{snapshot.id}_{today}.md"
    content = f"""# Codex Handoff: {snapshot.name}

## Current repo state

- Repo path: `{snapshot.repo_path}`
- Branch: `{snapshot.branch}`
- Latest commit: `{snapshot.latest_commit}`
- Dirty files: `{len(snapshot.dirty_files)}`
- TODO/NEXT markers: `{len(snapshot.todo_markers)}`
- Current phase: {snapshot.current_phase or 'Not set'}

## Safe instruction for Codex

You are working inside the `{snapshot.name}` repo. First inspect the repo before editing. Do not delete or overwrite existing work. Keep changes small, documented and reversible.

## Suggested next action

Review the dirty files, TODO/NEXT markers and docs status. Then propose the safest next implementation step.

## Files to check first

{chr(10).join('- `' + d + '`' for d in snapshot.docs_found[:20]) if snapshot.docs_found else '- No docs detected by scanner.'}

## Dirty files

{chr(10).join('- `' + f + '`' for f in snapshot.dirty_files[:50]) if snapshot.dirty_files else '- Working tree clean or unavailable.'}

## TODO/NEXT markers

{chr(10).join('- `' + item['file'] + ':' + str(item['line']) + '` — ' + item['text'] for item in snapshot.todo_markers[:30]) if snapshot.todo_markers else '- No TODO/NEXT markers detected.'}
"""
    path.write_text(content, encoding="utf-8")
    return path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", default=str(DEFAULT_CONFIG), help="Path to repo registry JSON")
    args = parser.parse_args()

    config_path = Path(args.config)
    config = json.loads(config_path.read_text(encoding="utf-8"))
    repos = config.get("repos", [])
    all_snapshots = []

    for repo in repos:
        snapshot = scan_repo(repo)
        write_snapshot(snapshot)
        write_progress_log(snapshot)
        write_codex_handoff(snapshot)
        all_snapshots.append(asdict(snapshot))
        print(f"Scanned {snapshot.name}: branch={snapshot.branch}, dirty={len(snapshot.dirty_files)}, todos={len(snapshot.todo_markers)}")

    dashboard_cache = MODULE_ROOT / "data" / "dashboard_cache" / "repo_scan_index.json"
    dashboard_cache.parent.mkdir(parents=True, exist_ok=True)
    dashboard_cache.write_text(json.dumps({"scanned_at": datetime.now(timezone.utc).isoformat(), "repos": all_snapshots}, indent=2), encoding="utf-8")
    print(f"Wrote dashboard cache: {dashboard_cache}")

if __name__ == "__main__":
    main()
