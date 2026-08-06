#!/usr/bin/env python3
"""
New Earth Project Repo Bridge - Omega OS Export

Copies generated progress logs and latest snapshots into configured Omega OS project folders.
Safe: only writes into configured omega_path folders.
"""

from __future__ import annotations

import json
import shutil
from datetime import datetime
from pathlib import Path

MODULE_ROOT = Path(__file__).resolve().parents[1]
UNIFIED = MODULE_ROOT / "data" / "unified" / "unified_projects.json"
SNAPSHOT_DIR = MODULE_ROOT / "data" / "repo_snapshots"
PROGRESS_DIR = MODULE_ROOT / "data" / "progress_logs"


def ensure(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def main() -> None:
    if not UNIFIED.exists():
        raise SystemExit("No unified_projects.json found. Run migrate_dashboard_projects.py first.")
    data = json.loads(UNIFIED.read_text(encoding="utf-8"))
    today = datetime.now().strftime("%Y-%m-%d")
    count = 0
    for project in data.get("projects", []):
        omega_path = project.get("omegaPath")
        repo_id = project.get("repoId")
        if not omega_path or not repo_id:
            continue
        root = Path(omega_path)
        build_logs = root / "BUILD_LOGS"
        snapshots = root / "REPO_SNAPSHOTS"
        codex = root / "CODEX_HANDOFFS"
        ensure(build_logs)
        ensure(snapshots)
        ensure(codex)

        progress = PROGRESS_DIR / f"{repo_id}_progress.md"
        snapshot = SNAPSHOT_DIR / f"{repo_id}_latest.json"
        handoff_candidates = sorted((MODULE_ROOT / "codex").glob(f"CODEX_HANDOFF_{repo_id}_*.md"))

        if progress.exists():
            shutil.copy2(progress, build_logs / f"{today}_{repo_id}_progress.md")
            count += 1
        if snapshot.exists():
            shutil.copy2(snapshot, snapshots / f"{today}_{repo_id}_snapshot.json")
            count += 1
        if handoff_candidates:
            shutil.copy2(handoff_candidates[-1], codex / handoff_candidates[-1].name)
            count += 1
    print(f"Omega export complete. Files copied: {count}")

if __name__ == "__main__":
    main()
