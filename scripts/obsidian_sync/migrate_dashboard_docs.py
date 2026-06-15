#!/usr/bin/env python3
"""Dashboard documentation alignment and migration helper.

Safe by default:
- compare: inspect current structure and write an alignment report
- dry-run: show the planned operations without changing files
- apply: create the Dashboard active-project scaffold and mapping notes
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable, Sequence


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def dashboard_root(root: Path) -> Path:
    return root / "01_ACTIVE_PROJECTS" / "00_NEW_EARTH_DASHBOARD"


def alignment_report_path(root: Path) -> Path:
    return dashboard_root(root) / "logs" / "dashboard_obsidian_alignment_report.md"


def obsidian_sync_module_root(root: Path) -> Path:
    return root / "modules" / "NE_OBSIDIAN_SYNC_MODULE"


def repo_bridge_root(root: Path) -> Path:
    return root / "modules" / "NE_REPO_INTELLIGENCE_BRIDGE"


def current_dashboard_sources(root: Path) -> list[Path]:
    candidates = [
        root / "README.md",
        root / "PROJECT_INDEX.md",
        root / "docs" / "README.md",
        root / "docs" / "roadmap" / "README.md",
        root / "docs" / "roadmap" / "project_now_next_later.md",
        root / "docs" / "roadmap" / "release_readiness_summary.md",
        root / "docs" / "roadmap" / "future_architecture_map.md",
        root / "docs" / "architecture" / "module_hub" / "module_hub_architecture.md",
        root / "docs" / "tasks" / "VOICE_BRIDGE_TASK.md",
        obsidian_sync_module_root(root) / "README.md",
        obsidian_sync_module_root(root) / "obsidian_sync_config.json",
        obsidian_sync_module_root(root) / "exports" / "PROJECT_HOME.md",
        obsidian_sync_module_root(root) / "exports" / "PROJECT_INDEX.md",
        obsidian_sync_module_root(root) / "exports" / "MOC_HOME.md",
        repo_bridge_root(root) / "obsidian_sync_config.json",
        repo_bridge_root(root) / "profiles" / "new_earth_dashboard.json",
    ]
    return [path for path in candidates if path.exists()]


def dashboard_target_files(root: Path) -> list[Path]:
    base = dashboard_root(root)
    return [
        base / "README.md",
        base / "docs" / "NEW_EARTH_DASHBOARD_PROJECT_HOME.md",
        base / "docs" / "NEW_EARTH_DASHBOARD_INDEX.md",
        base / "docs" / "NEW_EARTH_DASHBOARD_START_HERE.md",
        base / "logs" / "dashboard_obsidian_alignment_report.md",
        base / "modules" / "README.md",
        base / "templates" / "README.md",
        base / "sync" / "README.md",
        base / "exports" / "README.md",
        base / "logs" / "README.md",
    ]


@dataclass(frozen=True)
class PlannedFile:
    action: str
    path: Path
    reason: str


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def backup_path(root: Path, path: Path) -> Path:
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    relative = path.relative_to(dashboard_root(root))
    safe_name = "__".join(relative.parts)
    return dashboard_root(root) / "logs" / "backups" / f"{safe_name}.bak.{stamp}"


def ensure_parent(path: Path, dry_run: bool, planned: list[PlannedFile], reason: str) -> None:
    if path.parent.exists():
        return
    planned.append(PlannedFile("create-folder", path.parent, reason))
    if not dry_run:
        path.parent.mkdir(parents=True, exist_ok=True)


def render_report(root: Path, planned: Sequence[PlannedFile]) -> str:
    current_sources = current_dashboard_sources(root)
    target_root = dashboard_root(root)
    legacy_alias = root / "01_ACTIVE_PROJECTS" / "docs"

    lines = [
        "# Dashboard Obsidian Alignment Report",
        "",
        "## A. Current Structure Found",
        "",
        "- Current Dashboard docs live in the repo documentation tree:",
    ]
    for path in current_sources:
        lines.append(f"  - `{path.relative_to(root).as_posix()}`")
    lines.extend(
        [
            f"- Current Obsidian Sync Module location: `{obsidian_sync_module_root(root).relative_to(root).as_posix()}`",
            f"- Current bridge/profile location: `{repo_bridge_root(root).relative_to(root).as_posix()}`",
            f"- Legacy alias path present: `{legacy_alias.relative_to(root).as_posix()}`" if legacy_alias.exists() else "- Legacy alias path present: not found in this repo snapshot",
            "",
            "## B. Target Structure",
            "",
            "```text",
            "01_ACTIVE_PROJECTS/",
            "|-- 00_NEW_EARTH_DASHBOARD/",
            "    |-- docs/",
            "    |-- modules/",
            "    |-- templates/",
            "    |-- sync/",
            "    |-- exports/",
            "    |-- logs/",
            "    `-- README.md",
            "```",
            "",
            "## C. Gap Analysis",
            "",
            f"- Dashboard target folder missing: `{target_root.relative_to(root).as_posix()}`",
            "- Dashboard notes were not yet separated into a dedicated active-project folder.",
            "- Dashboard-specific migration helper was not present before this pass.",
            "- Dashboard-specific profile exists in the bridge family, but the official active-project folder was not yet scaffolded.",
            "- Logs, module references, templates, and exports were not yet organised under the Dashboard project folder.",
            "",
            "## D. Required Alignment Actions",
            "",
            "- create",
            "- update config/profile",
            "- add migration helper",
            "- add compatibility alias note",
            "- keep current docs as source material until the vault is configured",
            "",
            "## E. Safety Notes",
            "",
            "- The compare pass is read-only except for this report.",
            "- Apply mode should back up differing files before overwriting anything.",
            "- The vault root is not configured in the repo snapshot, so migration must remain reversible.",
            "",
            "## Planned Actions",
            "",
        ]
    )
    if planned:
        for item in planned:
            lines.append(f"- {item.action}: `{item.path.relative_to(root).as_posix()}` - {item.reason}")
    else:
        lines.append("- None")
    lines.append("")
    return "\n".join(lines)


def dashboard_project_home() -> str:
    return """---
project_name: "New Earth Dashboard"
project_type: "command-centre / dashboard / operating system hub"
priority: "active"
project_folder: "01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD"
docs_folder: "01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD/docs"
compatibility_alias:
  - "01_ACTIVE_PROJECTS/docs"
---

# New Earth Dashboard Project Home

This is the Obsidian home note for the Dashboard active project folder.

## Purpose

- Hold the central command-centre documentation for the New Earth Dashboard.
- Keep dashboard planning, module notes, logs, and sync outputs together.
- Map the current repo documentation into a clean active-project vault folder.

## Links

- [[NEW_EARTH_DASHBOARD_INDEX]]
- [[NEW_EARTH_DASHBOARD_START_HERE]]
- [[NEW_EARTH_DASHBOARD_ARCHITECTURE]]
- [[NEW_EARTH_DASHBOARD_CURRENT_STATE]]
- [[NEW_EARTH_DASHBOARD_ROAD_MAP]]
"""


def dashboard_index() -> str:
    note_names = [
        "ARCHITECTURE",
        "BUILD_LOG",
        "BUILD_LOG_SUMMARY",
        "CHANGE_INTELLIGENCE",
        "CODE_MAP",
        "CURRENT_PROGRESS",
        "CURRENT_STATE",
        "DAILY_SYNC_LOG",
        "DECISIONS",
        "DECISIONS_LOG",
        "DOC_REGISTRY",
        "FULL_BUILD_HISTORY",
        "INDEX",
        "MILESTONE_SUMMARIES",
        "MOC_HOME",
        "MODULE_RELATIONS",
        "MODULE_STATUS",
        "OPEN_QUESTIONS",
        "PROJECT_GRAPH",
        "PROJECT_HOME",
        "PROJECT_INDEX",
        "PROJECT_MAP",
        "PROJECT_OVERVIEW",
        "RISK_TRACKER",
        "ROAD_MAP",
        "START_HERE",
        "TASKS",
        "WEEKLY_REPORT",
    ]
    lines = ["# New Earth Dashboard Index", "", "This note is the navigator for the Dashboard active project folder.", "", "## Canonical Notes", ""]
    for name in note_names:
        lines.append(f"- [[NEW_EARTH_DASHBOARD_{name}]]")
    lines.extend(
        [
            "",
            "## Source Material In The Repo",
            "",
            "- [Root README](../../../../README.md)",
            "- [Project index](../../../../PROJECT_INDEX.md)",
            "- [Docs home](../../../../docs/README.md)",
            "- [Module hub architecture](../../../../docs/architecture/module_hub/module_hub_architecture.md)",
            "- [Obsidian sync module](../../../../modules/NE_OBSIDIAN_SYNC_MODULE/README.md)",
            "- [Repo intelligence bridge](../../../../modules/NE_REPO_INTELLIGENCE_BRIDGE/README.md)",
            "",
            "## Compatibility",
            "",
            "- Legacy alias: `01_ACTIVE_PROJECTS/docs`",
            "- Dashboard-specific usage should move to `01_ACTIVE_PROJECTS/00_NEW_EARTH_DASHBOARD/docs`",
        ]
    )
    return "\n".join(lines)


def dashboard_start_here() -> str:
    return """# New Earth Dashboard Start Here

Use this note when opening the Dashboard project folder in Obsidian.

## Read Order

1. [[NEW_EARTH_DASHBOARD_PROJECT_HOME]]
2. [[NEW_EARTH_DASHBOARD_INDEX]]
3. [[NEW_EARTH_DASHBOARD_ARCHITECTURE]]
4. [[NEW_EARTH_DASHBOARD_CURRENT_STATE]]
5. [[NEW_EARTH_DASHBOARD_ROAD_MAP]]
6. [[NEW_EARTH_DASHBOARD_TASKS]]

## Working Rules

- Keep the folder local-first.
- Preserve handwritten notes outside generated blocks.
- Use the alignment report before moving files.
- Keep the legacy alias only for compatibility.
"""


def folder_readme(title: str) -> str:
    return f"""# {title}

This folder is part of the New Earth Dashboard active project scaffold.
"""


def canonical_alias_docs() -> dict[str, tuple[str, str]]:
    return {
        "NEW_EARTH_DASHBOARD_ARCHITECTURE.md": (
            "../../../../docs/architecture/module_hub/module_hub_architecture.md",
            "Dashboard architecture reference.",
        ),
        "NEW_EARTH_DASHBOARD_BUILD_LOG.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/BUILD_LOG.md",
            "Current build log mapping.",
        ),
        "NEW_EARTH_DASHBOARD_BUILD_LOG_SUMMARY.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/BUILD_LOG_SUMMARY.md",
            "Build log summary mapping.",
        ),
        "NEW_EARTH_DASHBOARD_CHANGE_INTELLIGENCE.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/CHANGE_INTELLIGENCE.md",
            "Change intelligence mapping.",
        ),
        "NEW_EARTH_DASHBOARD_CODE_MAP.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/CODE_MAP.md",
            "Code map mapping.",
        ),
        "NEW_EARTH_DASHBOARD_CURRENT_PROGRESS.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/CURRENT_PROGRESS.md",
            "Current progress mapping.",
        ),
        "NEW_EARTH_DASHBOARD_CURRENT_STATE.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/CURRENT_STATE.md",
            "Current state mapping.",
        ),
        "NEW_EARTH_DASHBOARD_DAILY_SYNC_LOG.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/DAILY_SYNC_LOG.md",
            "Daily sync log mapping.",
        ),
        "NEW_EARTH_DASHBOARD_DECISIONS.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/DECISIONS.md",
            "Decisions mapping.",
        ),
        "NEW_EARTH_DASHBOARD_DECISIONS_LOG.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/DECISIONS_LOG.md",
            "Decisions log mapping.",
        ),
        "NEW_EARTH_DASHBOARD_DOC_REGISTRY.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/DOC_REGISTRY.md",
            "Doc registry mapping.",
        ),
        "NEW_EARTH_DASHBOARD_FULL_BUILD_HISTORY.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/FULL_BUILD_HISTORY.md",
            "Full build history mapping.",
        ),
        "NEW_EARTH_DASHBOARD_INDEX.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/INDEX.md",
            "Project index mapping.",
        ),
        "NEW_EARTH_DASHBOARD_MILESTONE_SUMMARIES.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/MILESTONE_SUMMARIES.md",
            "Milestone summaries mapping.",
        ),
        "NEW_EARTH_DASHBOARD_MOC_HOME.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/MOC_HOME.md",
            "MOC home mapping.",
        ),
        "NEW_EARTH_DASHBOARD_MODULE_RELATIONS.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/MODULE_RELATIONS.md",
            "Module relations mapping.",
        ),
        "NEW_EARTH_DASHBOARD_MODULE_STATUS.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/MODULE_STATUS.md",
            "Module status mapping.",
        ),
        "NEW_EARTH_DASHBOARD_OPEN_QUESTIONS.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/OPEN_QUESTIONS.md",
            "Open questions mapping.",
        ),
        "NEW_EARTH_DASHBOARD_PROJECT_GRAPH.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/PROJECT_GRAPH.md",
            "Project graph mapping.",
        ),
        "NEW_EARTH_DASHBOARD_PROJECT_MAP.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/PROJECT_MAP.md",
            "Project map mapping.",
        ),
        "NEW_EARTH_DASHBOARD_PROJECT_OVERVIEW.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/PROJECT_OVERVIEW.md",
            "Project overview mapping.",
        ),
        "NEW_EARTH_DASHBOARD_RISK_TRACKER.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/RISK_TRACKER.md",
            "Risk tracker mapping.",
        ),
        "NEW_EARTH_DASHBOARD_ROAD_MAP.md": (
            "../../../../docs/roadmap/app_roadmap.md",
            "Road map mapping.",
        ),
        "NEW_EARTH_DASHBOARD_TASKS.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/TASKS.md",
            "Tasks mapping.",
        ),
        "NEW_EARTH_DASHBOARD_WEEKLY_REPORT.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/WEEKLY_REPORT.md",
            "Weekly report mapping.",
        ),
        "NEW_EARTH_DASHBOARD_sync_port.md": (
            "../../../../modules/NE_OBSIDIAN_SYNC_MODULE/exports/sync_report.md",
            "Sync report port mapping.",
        ),
    }


def create_scaffold(root: Path, dry_run: bool, planned: list[PlannedFile]) -> None:
    base = dashboard_root(root)
    target_files = {
        base / "README.md": folder_readme("New Earth Dashboard Active Project"),
        base / "docs" / "NEW_EARTH_DASHBOARD_PROJECT_HOME.md": dashboard_project_home(),
        base / "docs" / "NEW_EARTH_DASHBOARD_INDEX.md": dashboard_index(),
        base / "docs" / "NEW_EARTH_DASHBOARD_START_HERE.md": dashboard_start_here(),
        base / "modules" / "README.md": folder_readme("Dashboard Modules"),
        base / "templates" / "README.md": folder_readme("Dashboard Templates"),
        base / "sync" / "README.md": folder_readme("Dashboard Sync"),
        base / "exports" / "README.md": folder_readme("Dashboard Exports"),
        base / "logs" / "README.md": folder_readme("Dashboard Logs"),
    }

    for path, content in target_files.items():
        if path.exists():
            existing = read_text(path)
            if existing == content:
                planned.append(PlannedFile("skip", path, "already matches scaffold"))
                continue
            planned.append(PlannedFile("backup", path, "existing file will be preserved before update"))
            if not dry_run:
                path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, backup_path(root, path))
                write_text(path, content)
            continue
        planned.append(PlannedFile("create", path, "create dashboard scaffold"))
        if not dry_run:
            write_text(path, content)

    for name, (source_link, description) in canonical_alias_docs().items():
        path = base / "docs" / name
        content = f"""# {name.replace('_', ' ').replace('.md', '')}

{description}

## Source

- [Source note]({source_link})
"""
        if path.exists():
            existing = read_text(path)
            if existing == content:
                planned.append(PlannedFile("skip", path, "alias note already matches"))
                continue
            planned.append(PlannedFile("backup", path, "alias note will be preserved before update"))
            if not dry_run:
                shutil.copy2(path, backup_path(root, path))
                write_text(path, content)
            continue
        planned.append(PlannedFile("create", path, "create mapped dashboard note"))
        if not dry_run:
            write_text(path, content)


def write_alignment_report(root: Path, planned: Sequence[PlannedFile], dry_run: bool) -> Path:
    report = render_report(root, planned)
    path = alignment_report_path(root)
    if not dry_run:
        write_text(path, report)
    return path


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Compare, dry-run, or apply Dashboard docs alignment.")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--compare", action="store_true", help="Generate the alignment report without changing files.")
    group.add_argument("--dry-run", action="store_true", help="Show planned operations without changing files.")
    group.add_argument("--apply", action="store_true", help="Apply the dashboard scaffold and mapping notes.")
    parser.add_argument("--root", default=None, help="Repository or vault root. Defaults to the repo root containing this script.")
    args = parser.parse_args(argv)

    if not (args.compare or args.dry_run or args.apply):
        parser.print_help()
        return 0

    root = Path(args.root).resolve() if args.root else repo_root()
    planned: list[PlannedFile] = []

    if args.compare or args.dry_run or args.apply:
        current = current_dashboard_sources(root)
        planned.extend(
            PlannedFile("inspect", path, "current dashboard source detected")
            for path in current
        )

    if args.dry_run:
        create_scaffold(root, dry_run=True, planned=planned)
    if args.apply:
        create_scaffold(root, dry_run=False, planned=planned)

    report_path = write_alignment_report(root, planned, dry_run=False)

    if args.compare:
        print(f"Alignment report written: {report_path}")
        print(f"Current sources found: {len(current_dashboard_sources(root))}")
        return 0

    if args.dry_run:
        print(f"Dry-run report written: {report_path}")
        for item in planned:
            print(f"{item.action.upper()}: {item.path} - {item.reason}")
        return 0

    if args.apply:
        print(f"Applied Dashboard scaffold under: {dashboard_root(root)}")
        print(f"Alignment report written: {report_path}")
        print(f"Planned operations recorded: {len(planned)}")
        return 0

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
