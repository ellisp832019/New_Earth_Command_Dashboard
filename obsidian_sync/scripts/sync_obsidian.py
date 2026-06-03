#!/usr/bin/env python3
"""Local-first Obsidian/Omega OS documentation sync.

This tool scans the current repo, generates Obsidian-ready Markdown exports,
and optionally mirrors them into a configured vault folder.
"""

from __future__ import annotations

import argparse
import dataclasses
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Iterable, List, Sequence, Tuple


AUTO_START = "<!-- AUTO-GENERATED:START -->"
AUTO_END = "<!-- AUTO-GENERATED:END -->"

TEXT_EXTENSIONS = {
    ".md",
    ".txt",
    ".dart",
    ".py",
    ".ps1",
    ".sh",
    ".json",
    ".yaml",
    ".yml",
    ".ts",
    ".tsx",
    ".html",
    ".xml",
    ".c",
    ".cc",
    ".cpp",
    ".h",
    ".kts",
    ".gradle",
    ".ini",
    ".toml",
}


@dataclasses.dataclass(frozen=True)
class SyncConfig:
    project_name: str
    project_type: str
    source_repo_path: str
    obsidian_vault_path: str
    obsidian_project_folder: str
    vault_note_prefix: str
    export_docs: List[str]
    watched_paths: List[str]
    watched_file_patterns: List[str]
    ignore_paths: List[str]
    sync_interval_seconds: int
    history_limit: int


@dataclasses.dataclass
class SyncResult:
    changed_files: List[str]
    added_files: List[str]
    removed_files: List[str]
    updated_docs: List[str]
    copied_docs: List[str]
    skipped_copy: bool
    status: str
    message: str


def load_config(config_path: Path) -> SyncConfig:
    if not config_path.exists():
        raise FileNotFoundError(f"Config not found: {config_path}")

    raw = json.loads(config_path.read_text(encoding="utf-8"))
    return SyncConfig(
        project_name=raw.get("project_name", "Unnamed Project"),
        project_type=raw.get("project_type", "app"),
        source_repo_path=raw.get("source_repo_path", ".."),
        obsidian_vault_path=raw.get("obsidian_vault_path", ""),
        obsidian_project_folder=raw.get("obsidian_project_folder", ""),
        vault_note_prefix=raw.get("vault_note_prefix", ""),
        export_docs=list(
            raw.get(
                "export_docs",
                [
                    "PROJECT_OVERVIEW.md",
                    "CURRENT_PROGRESS.md",
                    "DECISIONS_LOG.md",
                    "BUILD_LOG.md",
                    "CODE_MAP.md",
                    "TASKS.md",
                    "OPEN_QUESTIONS.md",
                    "DAILY_SYNC_LOG.md",
                ],
            )
        ),
        watched_paths=list(
            raw.get(
                "watched_paths",
                [
                    "README.md",
                    "TASK.md",
                    "CHANGELOG.md",
                    "docs",
                    "lib",
                    "modules",
                    "assets",
                    "config",
                    "tools",
                    "scripts",
                    "firmware",
                    "software",
                    "hardware",
                    "android",
                    "ios",
                    "linux",
                    "macos",
                    "web",
                    "windows",
                ],
            )
        ),
        watched_file_patterns=list(
            raw.get(
                "watched_file_patterns",
                [
                    "README*.md",
                    "*.md",
                    "*.yaml",
                    "*.yml",
                    "*.json",
                    "*.dart",
                    "*.py",
                    "*.ps1",
                    "*.sh",
                    "*.ts",
                    "*.tsx",
                    "*.txt",
                ],
            )
        ),
        ignore_paths=list(
            raw.get(
                "ignore_paths",
                [
                    ".git",
                    "build",
                    ".dart_tool",
                    "node_modules",
                    "__pycache__",
                    "dist",
                    ".next",
                    "obsidian_sync",
                    "modules/NE_OBSIDIAN_SYNC_MODULE",
                    ".sync_state.json",
                ],
            )
        ),
        sync_interval_seconds=int(raw.get("sync_interval_seconds", 10)),
        history_limit=int(raw.get("history_limit", 30)),
    )


def resolve_path(base: Path, candidate: str) -> Path:
    candidate_path = Path(candidate)
    if candidate_path.is_absolute():
        return candidate_path.resolve()
    return (base / candidate_path).resolve()


def safe_mkdir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def write_text_if_changed(path: Path, content: str) -> bool:
    if path.exists() and read_text(path) == content:
        return False
    safe_mkdir(path.parent)
    path.write_text(content, encoding="utf-8", newline="\n")
    return True


def sha1_text(text: str) -> str:
    return hashlib.sha1(text.encode("utf-8")).hexdigest()


def sha1_file(path: Path) -> str:
    return hashlib.sha1(path.read_bytes()).hexdigest()


def is_ignored(path: Path, repo_root: Path, ignore_terms: Sequence[str]) -> bool:
    rel = path.relative_to(repo_root).as_posix()
    parts = set(path.parts)
    return any(term in rel or term in parts for term in ignore_terms)


def collect_files(
    repo_root: Path, watched_paths: Sequence[str], patterns: Sequence[str], ignore_terms: Sequence[str]
) -> List[Path]:
    files: Dict[str, Path] = {}

    def add_file(candidate: Path) -> None:
        if not candidate.exists() or not candidate.is_file():
            return
        try:
            candidate.relative_to(repo_root)
        except ValueError:
            return
        if is_ignored(candidate, repo_root, ignore_terms):
            return
        files[candidate.as_posix()] = candidate

    for item in watched_paths:
        target = repo_root / item
        if "*" in item or "?" in item:
            for match in repo_root.rglob(item):
                add_file(match)
            continue
        if target.is_file():
            add_file(target)
            continue
        if target.is_dir():
            for match in target.rglob("*"):
                add_file(match)
            continue
        # Fallback for folder names that may not exist in every repo.
        for match in repo_root.rglob(item):
            add_file(match)

    for pattern in patterns:
        for match in repo_root.glob(pattern):
            add_file(match)

    return sorted(files.values(), key=lambda p: p.as_posix().lower())


def build_snapshot(repo_root: Path, config: SyncConfig) -> Dict[str, str]:
    snapshot: Dict[str, str] = {}
    for file_path in collect_files(repo_root, config.watched_paths, config.watched_file_patterns, config.ignore_paths):
        rel = file_path.relative_to(repo_root).as_posix()
        try:
            snapshot[rel] = sha1_file(file_path)
        except OSError:
            continue
    return snapshot


def diff_snapshots(previous: Dict[str, str], current: Dict[str, str]) -> Tuple[List[str], List[str], List[str]]:
    prev_keys = set(previous)
    curr_keys = set(current)
    changed = sorted([key for key in (prev_keys & curr_keys) if previous[key] != current[key]])
    added = sorted(curr_keys - prev_keys)
    removed = sorted(prev_keys - curr_keys)
    return changed, added, removed


def extract_between(text: str, start: str, end: str) -> str | None:
    pattern = re.compile(re.escape(start) + r"\s*(.*?)\s*" + re.escape(end), re.DOTALL)
    match = pattern.search(text)
    if not match:
        return None
    return match.group(1).strip()


def replace_autogen_block(existing: str, body: str) -> str:
    block = f"{AUTO_START}\n{body.rstrip()}\n{AUTO_END}"
    if AUTO_START in existing and AUTO_END in existing:
        pattern = re.compile(
            re.escape(AUTO_START) + r".*?" + re.escape(AUTO_END),
            re.DOTALL,
        )
        return pattern.sub(lambda _: block, existing, count=1).rstrip() + "\n"
    if existing.strip():
        return existing.rstrip() + "\n\n" + block + "\n"
    return block + "\n"


def heading_block(title: str, notes: str, body: str) -> str:
    parts = [f"# {title}"]
    if notes.strip():
        parts.extend(["", notes.strip()])
    parts.extend(["", AUTO_START, body.rstrip(), AUTO_END])
    return "\n".join(parts).rstrip() + "\n"


def extract_section(markdown: str, heading: str) -> str:
    pattern = re.compile(
        rf"^##\s+{re.escape(heading)}\s*$([\s\S]*?)(?=^##\s+|\Z)",
        re.MULTILINE,
    )
    match = pattern.search(markdown)
    return match.group(1).strip() if match else ""


def extract_first_heading_block(markdown: str) -> str:
    lines = markdown.splitlines()
    start = None
    for index, line in enumerate(lines):
        if line.startswith("# "):
            start = index
            break
    if start is None:
        return markdown.strip()
    end = len(lines)
    for index in range(start + 1, len(lines)):
        if lines[index].startswith("# "):
            end = index
            break
    return "\n".join(lines[start:end]).strip()


def extract_latest_dated_entry(markdown: str) -> str:
    lines = markdown.splitlines()
    start = None
    date_heading = re.compile(r"^#+\s+\d{4}-\d{2}-\d{2}\s+-\s+.+$")
    for index, line in enumerate(lines):
        if date_heading.match(line.strip()):
            start = index
            break
    if start is None:
        return extract_first_heading_block(markdown)

    end = len(lines)
    current_level = len(lines[start]) - len(lines[start].lstrip("#"))
    for index in range(start + 1, len(lines)):
        line = lines[index]
        if line.startswith("#"):
            level = len(line) - len(line.lstrip("#"))
            if level <= current_level:
                end = index
                break
    return "\n".join(lines[start:end]).strip()


def bullet_items(markdown: str, heading: str) -> List[str]:
    section = extract_section(markdown, heading)
    items: List[str] = []
    for line in section.splitlines():
        stripped = line.strip()
        cleaned = re.sub(r"^([-*]|\d+\.)\s+", "", stripped).strip()
        if cleaned and (
            stripped.startswith("-")
            or stripped.startswith("*")
            or re.match(r"^\d+\.", stripped)
        ):
            items.append(cleaned)
    return items


def table_rows(markdown: str) -> List[str]:
    rows = []
    for line in markdown.splitlines():
        if line.startswith("|") and line.count("|") >= 2:
            rows.append(line)
    return rows


def read_if_exists(path: Path) -> str:
    return read_text(path) if path.exists() else ""


def git_info(repo_root: Path) -> Dict[str, str]:
    def run_git(*args: str) -> str:
        try:
            result = subprocess.run(
                ["git", *args],
                cwd=repo_root,
                capture_output=True,
                text=True,
                check=True,
            )
            return result.stdout.strip()
        except Exception:
            return ""

    return {
        "branch": run_git("branch", "--show-current"),
        "commit": run_git("describe", "--tags", "--always", "--dirty"),
        "status": run_git("status", "--short"),
        "last_commit": run_git("log", "-1", "--pretty=%ad|%h|%s", "--date=short"),
    }


def scan_todos(repo_root: Path, config: SyncConfig) -> List[str]:
    matches: List[str] = []
    todo_pattern = re.compile(r"\b(TODO|FIXME|WIP|HACK|REVIEW)\b|(?<![A-Z_])NEXT(?![A-Z_])", re.IGNORECASE)
    for path in collect_files(repo_root, config.watched_paths, config.watched_file_patterns, config.ignore_paths):
        if path.suffix.lower() not in TEXT_EXTENSIONS and path.name not in {"README", "TASK"}:
            continue
        try:
            content = read_text(path)
        except OSError:
            continue
        for index, line in enumerate(content.splitlines(), start=1):
            if todo_pattern.search(line):
                rel = path.relative_to(repo_root).as_posix()
                matches.append(f"{rel}:{index}: {line.strip()}")
    return matches[:60]


def parse_commit_lines(repo_root: Path, limit: int = 12) -> List[Tuple[str, str, str]]:
    try:
        result = subprocess.run(
            ["git", "log", f"--max-count={limit}", "--date=short", "--pretty=format:%ad|%h|%s"],
            cwd=repo_root,
            capture_output=True,
            text=True,
            check=True,
        )
    except Exception:
        return []

    commits = []
    for line in result.stdout.splitlines():
        if "|" not in line:
            continue
        date, sha, subject = line.split("|", 2)
        commits.append((date.strip(), sha.strip(), subject.strip()))
    return commits


def summarize_repo(repo_root: Path, config: SyncConfig) -> Dict[str, object]:
    readme = read_if_exists(repo_root / "README.md")
    docs_home = read_if_exists(repo_root / "docs" / "README.md")
    task_md = read_if_exists(repo_root / "TASK.md")
    roadmap = read_if_exists(repo_root / "docs" / "roadmap" / "app_roadmap.md")
    ai_roadmap = read_if_exists(repo_root / "docs" / "roadmap" / "ai_10_task_roadmap.md")
    architecture = read_if_exists(repo_root / "docs" / "architecture" / "architecture_decisions.md")
    development_log = read_if_exists(repo_root / "docs" / "developer_guide" / "development_log.md")
    fsd_index = read_if_exists(repo_root / "docs" / "fsd" / "00_master_index.md")
    current_git = git_info(repo_root)

    current_status = bullet_items(readme, "Current Status")
    docs_links = bullet_items(docs_home, "Start Here")
    next_actions = bullet_items(roadmap, "Immediate Next Actions")
    roadmap_near_term = bullet_items(roadmap, "Near-Term Summary")
    roadmap_not_yet = bullet_items(roadmap, "Not Yet")
    roadmap_immediate = bullet_items(ai_roadmap, "Do First")
    architecture_decisions = table_rows(architecture)
    task_lines = [line.strip() for line in task_md.splitlines() if line.strip()]
    devlog_summary = extract_latest_dated_entry(development_log)
    recent_commits = parse_commit_lines(repo_root, 14)
    todos = scan_todos(repo_root, config)

    return {
        "readme": readme,
        "docs_home": docs_home,
        "task_md": task_md,
        "roadmap": roadmap,
        "ai_roadmap": ai_roadmap,
        "architecture": architecture,
        "development_log": development_log,
        "fsd_index": fsd_index,
        "current_status": current_status,
        "docs_links": docs_links,
        "next_actions": next_actions,
        "roadmap_near_term": roadmap_near_term,
        "roadmap_not_yet": roadmap_not_yet,
        "roadmap_immediate": roadmap_immediate,
        "architecture_decisions": architecture_decisions,
        "task_lines": task_lines,
        "devlog_summary": devlog_summary,
        "git": current_git,
        "recent_commits": recent_commits,
        "todos": todos,
    }


def render_list(items: Iterable[str], indent: str = "- ") -> str:
    lines = [f"{indent}{item}" for item in items]
    return "\n".join(lines) if lines else f"{indent}None recorded yet."


def render_table(rows: Sequence[Sequence[str]]) -> str:
    if not rows:
        return "| Item | Value |\n|---|---|\n| None | None |"
    header = rows[0]
    body = rows[1:]
    lines = [
        "| " + " | ".join(header) + " |",
        "| " + " | ".join(["---"] * len(header)) + " |",
    ]
    lines.extend("| " + " | ".join(row) + " |" for row in body)
    return "\n".join(lines)


def generate_project_overview(context: Dict[str, object], config: SyncConfig) -> str:
    status = context["current_status"] or []
    next_actions = context["next_actions"] or context["roadmap_immediate"] or []
    recent_commits = context["recent_commits"][:6]

    body = "\n".join(
        [
            "## What This Project Is",
            f"- {config.project_name} is a {config.project_type} in the New Earth ecosystem.",
            "- It is local-first and offline-first by design.",
            "- It uses Flutter, Material 3, and a feature-based structure.",
            "",
            "## Current Purpose",
            "- Keep the daily workflow calm, clear, and review-first.",
            "- Support projects, tasks, capture, planning, and progress tracking without cloud dependency.",
            "",
            "## What Currently Works",
            render_list(status),
            "",
            "## Current Scope Guardrails",
            "- No login in V0.1.",
            "- No cloud sync in V0.1.",
            "- No live calendar, GitHub, WordPress, or MicroGrow integration yet.",
            "- No AI assistant in V0.1.",
            "",
            "## Current Branch And Repo Signal",
            f"- Branch: `{context['git']['branch'] or 'unknown'}`",
            f"- Current commit snapshot: `{context['git']['commit'] or 'unknown'}`",
            "",
            "## Next Priority Actions",
            render_list(next_actions),
            "",
            "## Related Docs",
            render_list(
                [
                    "[[CURRENT_PROGRESS]]",
                    "[[CODE_MAP]]",
                    "[[DECISIONS_LOG]]",
                    "[[BUILD_LOG]]",
                    "`README.md`",
                    "`docs/README.md`",
                    "`docs/roadmap/app_roadmap.md`",
                    "`docs/architecture/architecture_decisions.md`",
                ]
            ),
            "",
            "## Recent Commits",
            render_list([f"`{sha}` {subject} ({date})" for date, sha, subject in recent_commits]),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Project Overview",
        "Handwritten notes can be added above or below the autogenerated block.",
        body,
    )


def generate_current_progress(context: Dict[str, object], config: SyncConfig, changed_files: Sequence[str]) -> str:
    works = context["current_status"] or []
    incomplete = []
    incomplete.extend(bullet_items(context["readme"], "What Is Incomplete"))
    if not incomplete:
        incomplete.extend(context["roadmap_not_yet"])
    if not incomplete:
        incomplete.extend(
            [
                "No login in V0.1.",
                "No cloud sync in V0.1.",
                "No live calendar, GitHub, WordPress, or MicroGrow integration yet.",
                "No AI assistant in V0.1.",
            ]
        )

    risks = bullet_items(context["readme"], "Current Risks")
    if not risks:
        risks = bullet_items(context["roadmap"], "Working Principles")
    if not risks:
        risks = [
            "The app surface is broad, so routing and docs can drift if too many slices move at once.",
            "Windows-specific voice dependencies can vary by machine.",
            "Local file paths and asset/config assumptions need to stay stable.",
            "Too many parallel feature slices could dilute MVP focus.",
        ]

    next_actions = context["next_actions"] or context["roadmap_immediate"] or []

    body = "\n".join(
        [
            "## What Works",
            render_list(works),
            "",
            "## What Is Incomplete",
            render_list(incomplete),
            "",
            "## Current Risks",
            render_list(risks),
            "",
            "## Next Priority Actions",
            render_list(next_actions),
            "",
            "## Last Sync Signal",
            f"- Changed source files in this run: {len(changed_files)}",
            f"- Branch: `{context['git']['branch'] or 'unknown'}`",
            f"- Commit snapshot: `{context['git']['commit'] or 'unknown'}`",
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Current Progress",
        "Use this note for the live project state. The sync tool only edits the autogenerated block.",
        body,
    )


def generate_decisions_log(context: Dict[str, object], config: SyncConfig) -> str:
    rows = []
    architecture = context["architecture"]
    for line in architecture.splitlines():
        if line.startswith("## ADR"):
            current = line.replace("## ", "").strip()
            rows.append(current)
    if not rows:
        rows = [
            "Local-first and offline-first for V0.1",
            "Feature-based Flutter structure",
            "go_router for navigation",
            "Riverpod for state management",
        ]

    table = []
    for item in rows[:10]:
        decision = item
        reason = "Recorded in the project architecture notes."
        status = "Active"
        if "001" in item:
            decision = "Local-first and offline-first for V0.1"
            reason = "The app must work without login, cloud sync, or external services."
        elif "002" in item:
            decision = "Feature-based Flutter structure"
            reason = "Large module count stays understandable when each feature is isolated."
        elif "003" in item:
            decision = "Use go_router for navigation"
            reason = "The app needs clear route names and nested navigation."
        elif "004" in item:
            decision = "Use Riverpod when state is needed"
            reason = "State should stay explicit and testable."
        elif "005" in item:
            decision = "Separate documentation visuals from app UI"
            reason = "The brand assets are bold while the app UI must stay calm."
        table.append((decision, reason, status))

    open_decisions = []
    open_decisions.extend(bullet_items(context["ai_roadmap"], "Open Decisions"))
    if not open_decisions:
        open_decisions = [
            "How much of the Obsidian sync module should be copied into each downstream repo.",
            "When to activate the AI adapter beyond the current roadmap stub.",
            "Whether the next active slice should stay on voice polish or move to asset intelligence.",
        ]

    body = "\n".join(
        [
            "## Decision Log",
            render_table([("Decision", "Reason", "Status")] + [tuple(map(str, row)) for row in table]),
            "",
            "## Key Technical Decisions",
            render_list([row[0] for row in table]),
            "",
            "## Alternatives Considered",
            "- Cloud-first storage and login were rejected for V0.1.",
            "- A flatter folder structure was considered but would not scale well for the current module count.",
            "- A different state management approach was considered, but Riverpod fits the local data flow well.",
            "",
            "## Open Decisions",
            render_list(open_decisions),
            "",
            "## Decisions That Need Peter's Review",
            "- The next priority after voice polish.",
            "- How quickly AI should move beyond the adapter contract.",
            "- Whether the sync module should remain a repo-local tool or be copied into every downstream project.",
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Decisions Log",
        "The decision block is generated from repo docs and architecture notes.",
        body,
    )


def generate_build_log(context: Dict[str, object], config: SyncConfig, changed_files: Sequence[str]) -> str:
    devlog = context["devlog_summary"]
    commits = context["recent_commits"][:5]
    commit_list = [f"`{sha}` {subject} ({date})" for date, sha, subject in commits]
    changed = [f"`{file}`" for file in changed_files[:25]]
    if not changed:
        changed = ["No watched source changes detected in this run."]
    tested = []
    if "flutter analyze" in context["development_log"].lower():
        tested.append("`flutter analyze` has been part of the recorded development workflow.")
    if "flutter test" in context["development_log"].lower():
        tested.append("`flutter test` has been part of the recorded development workflow.")
    if "flutter build windows" in context["development_log"].lower():
        tested.append("`flutter build windows` has been part of the recorded development workflow.")
    if not tested:
        tested = ["This sync run did not execute app tests."]

    known_issues = bullet_items(context["readme"], "Current Risks")
    if not known_issues:
        known_issues = [
            "Voice and routing work are broad and need careful sequencing.",
            "Windows voice dependencies can vary by machine.",
            "Documentation can drift if sync is not run regularly.",
        ]

    next_step = context["roadmap_immediate"][:1] or context["next_actions"][:1] or ["Finish the next active local-first slice."]

    body = "\n".join(
        [
            "## Latest Progress",
            devlog or "- No development log summary found.",
            "",
            "## What Changed",
            render_list(changed),
            "",
            "## Recent Commits",
            render_list(commit_list),
            "",
            "## What Was Tested",
            render_list(tested),
            "",
            "## Known Issues",
            render_list(known_issues),
            "",
            "## Next Build Step",
            render_list(next_step),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Build Log",
        "This note tracks the build and sync picture for the current repo.",
        body,
    )


def generate_code_map(context: Dict[str, object], config: SyncConfig, repo_root: Path) -> str:
    important_roots = [
        ("`lib/`", "Flutter application source, feature modules, core services, routing, and UI widgets."),
        ("`docs/`", "Functional specs, roadmap notes, guides, and architecture decisions."),
        ("`modules/`", "Supporting modules such as meeting system, repo bridge, and sync tooling."),
        ("`assets/`", "Visual assets, screenshots, guides, and brand material."),
        ("`config/`", "Local path and asset configuration files."),
        ("`tools/`", "Local helper scripts such as the desktop voice bridge."),
        ("`third_party/`", "Vendored dependencies and platform-specific wrappers."),
        ("`obsidian_sync/`", "This sync module, generated exports, templates, and scripts."),
    ]

    feature_root = repo_root / "lib" / "features"
    feature_groups = []
    if feature_root.exists():
        for child in sorted([p for p in feature_root.iterdir() if p.is_dir()], key=lambda p: p.name):
            count = sum(1 for _ in child.rglob("*") if _.is_file())
            feature_groups.append((f"`lib/features/{child.name}/`", f"{count} tracked files"))

    top_files = []
    for filename in ["README.md", "TASK.md", "pubspec.yaml", "analysis_options.yaml"]:
        path = repo_root / filename
        if path.exists():
            top_files.append((f"`{filename}`", "Top-level repo guidance or configuration."))

    data_flow = [
        "User action in a feature screen",
        "Riverpod controller or local service",
        "Drift database, file workflow, or local helper",
        "State refresh and updated UI",
    ]

    dependencies = [
        "Flutter and Material 3",
        "`go_router`",
        "`flutter_riverpod`",
        "`drift` and SQLite",
        "`speech_to_text` and the Windows speech bridge",
        "`path_provider`, `path`, `uuid`, `file_picker`, `qr_flutter`, `pdf`, and `printing`",
    ]

    integrations = [
        "Local SQLite database",
        "Local filesystem exports and caches",
        "Windows voice typing and headset gate flow",
        "QR labels and PDF print workflows",
        "Obsidian sync exports for long-term project memory",
        "Omega OS / repo bridge supporting modules",
    ]

    body = "\n".join(
        [
            "## System Overview",
            f"{config.project_name} is a local-first Flutter app with a feature-based folder structure and a router-driven shell.",
            "",
            "## Main Components",
            render_table([("Component", "Purpose")] + important_roots + feature_groups[:10] + top_files),
            "",
            "## Important Folders",
            render_list([f"{path} - {purpose}" for path, purpose in important_roots + feature_groups[:8]]),
            "",
            "## Data Flow",
            render_list(data_flow),
            "",
            "## External Dependencies",
            render_list([f"`{item}`" if not item.startswith("`") else item for item in dependencies]),
            "",
            "## Integration Points",
            render_list(integrations),
            "",
            "## Known Architecture Risks",
            "- The router and feature count are large and need discipline.",
            "- Voice session ownership must stay singular to avoid lifecycle collisions.",
            "- Windows speech and headset handling vary by hardware and environment.",
            "- Local file workflows can drift if config paths are not kept consistent.",
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Code Map",
        "This note maps the important source areas and their roles.",
        body,
    )


def generate_tasks(context: Dict[str, object], config: SyncConfig) -> str:
    immediate = context["roadmap_immediate"] or context["next_actions"]
    if not immediate:
        immediate = [
            "Finish the current local-first slice.",
            "Keep the docs and build notes aligned.",
            "Avoid widening scope before the current slice is stable.",
        ]
    month_plan = {
        "Week 1": "Finish voice polish and reduce any rough edges in the assistant flow.",
        "Week 2": "Harden asset intelligence and QR/print workflows.",
        "Week 3": "Keep knowledge library and local file workflows stable.",
        "Week 4": "Only start the AI adapter path if the voice path remains calm.",
    }
    three_month = [
        "Keep the core dashboard, capture, projects, and tasks loop reliable.",
        "Stabilize the voice stack before layering in AI assist.",
        "Harden treasury, assets, and knowledge workflows for day-to-day use.",
    ]
    future = [
        "Optional AI assist through a small adapter contract.",
        "Cloud sync only after the local-first foundation is strong.",
        "Calendar, GitHub, WordPress, and MicroGrow live integrations later.",
    ]
    not_yet = context["roadmap_not_yet"] or [
        "Login.",
        "Cloud sync.",
        "Full AI assistant.",
        "Large UI redesigns.",
        "Broad architecture rewrites.",
    ]

    body = "\n".join(
        [
            "## Immediate Next Actions",
            render_list(immediate),
            "",
            "## 4 Week Plan",
            "\n".join([f"### {week}\n\n- {desc}" for week, desc in month_plan.items()]),
            "",
            "## 3 Month Direction",
            render_list(three_month),
            "",
            "## Future Expansion",
            render_list(future),
            "",
            "## Not Yet",
            "These are useful later, but not the current focus:",
            "",
            render_list(not_yet),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Tasks",
        "This note tracks the next practical actions and what stays parked for now.",
        body,
    )


def generate_open_questions(context: Dict[str, object], config: SyncConfig, changed_files: Sequence[str]) -> str:
    todos = context["todos"][:20]
    questions = []
    questions.extend(
        [
            "Should the sync module stay in the repo as a local tool, or be copied into each downstream project?",
            "Do the generated notes need a shorter vault folder name for Omega OS destinations?",
            "Should the next active code slice stay on voice polish or move to asset intelligence first?",
            "When should the AI adapter move beyond roadmap-only status?",
        ]
    )
    if todos:
        questions.append("TODO / NEXT markers found in the repo:")
    body_lines = [
        "## Open Questions",
        render_list(questions),
        "",
        "## TODO Markers",
        render_list([f"`{item}`" for item in todos] if todos else ["No TODO markers found in the watched scope."]),
        "",
        "## Sync Considerations",
        "- The vault destination should be a real, configured path before mirror mode is used.",
        f"- This run detected {len(changed_files)} changed watched source files.",
        "- Hand-written vault notes are preserved unless the autogenerated block is present.",
    ]
    return heading_block(
        f"{config.project_name} Open Questions",
        "Questions and unresolved items belong here so they are visible during planning.",
        "\n".join(body_lines).strip(),
    )


def load_sync_state(state_path: Path) -> Dict[str, object]:
    if not state_path.exists():
        return {"history": [], "snapshot": {}}
    try:
        return json.loads(read_text(state_path))
    except json.JSONDecodeError:
        return {"history": [], "snapshot": {}}


def save_sync_state(state_path: Path, state: Dict[str, object]) -> None:
    safe_mkdir(state_path.parent)
    state_path.write_text(json.dumps(state, indent=2, ensure_ascii=False), encoding="utf-8")


def update_daily_sync_log(
    history: Sequence[Dict[str, object]],
    config: SyncConfig,
    result: SyncResult,
    repo_root: Path,
    destination: Path | None,
) -> str:
    history = list(history)[: config.history_limit]
    lines = [
        "## Sync History",
        "",
        "| Timestamp | Status | Changed Files | Updated Docs | Copied Docs | Note |",
        "|---|---|---:|---:|---:|---|",
    ]
    for entry in history:
        note = str(entry.get("message", "")).replace("|", "\\|")
        lines.append(
            f"| {entry.get('timestamp', '')} | {entry.get('status', '')} | {len(entry.get('changed_files', []))} | {len(entry.get('updated_docs', []))} | {len(entry.get('copied_docs', []))} | {note} |"
        )
    lines.extend(
        [
            "",
            "## Latest Run Details",
            f"- Project: {config.project_name}",
            f"- Repo root: `{repo_root}`",
            f"- Vault destination: `{destination}`" if destination else "- Vault destination: not configured or unavailable.",
            f"- Changed watched source files: {len(result.changed_files)}",
            f"- Updated export docs: {', '.join(result.updated_docs) if result.updated_docs else 'None'}",
            f"- Copied docs: {', '.join(result.copied_docs) if result.copied_docs else 'None'}",
        ]
    )
    return heading_block(
        f"{config.project_name} Daily Sync Log",
        "Append-only sync history. Handwritten notes can live above or below the autogenerated block.",
        "\n".join(lines).strip(),
    )


def mirror_to_vault(
    export_root: Path,
    vault_root: Path,
    destination_root: Path,
    docs: Sequence[str],
    vault_note_prefix: str,
) -> List[str]:
    copied = []
    if not vault_root.exists():
        return copied
    if not destination_root.exists():
        safe_mkdir(destination_root)
    for doc in docs:
        src = export_root / doc
        if not src.exists():
            continue
        dst = destination_root / f"{vault_note_prefix}{doc}" if vault_note_prefix else destination_root / doc
        src_text = read_text(src)
        if dst.exists():
            existing = read_text(dst)
            merged = replace_autogen_block(existing, extract_between(src_text, AUTO_START, AUTO_END) or src_text)
            if merged != existing:
                dst.write_text(merged, encoding="utf-8", newline="\n")
                copied.append(doc)
        else:
            dst.write_text(src_text, encoding="utf-8", newline="\n")
            copied.append(doc)
    return copied


def ensure_export_docs(export_root: Path, docs: Dict[str, str]) -> List[str]:
    updated = []
    safe_mkdir(export_root)
    for name, content in docs.items():
        path = export_root / name
        if write_text_if_changed(path, content):
            updated.append(name)
    return updated


def run_sync(config_path: Path) -> SyncResult:
    module_root = config_path.parent
    config = load_config(config_path)
    repo_root = resolve_path(module_root, config.source_repo_path)
    export_root = module_root / "exports"
    daily_path = export_root / "DAILY_SYNC_LOG.md"
    state_path = module_root / ".sync_state.json"
    existing_state = load_sync_state(state_path)
    previous_snapshot = existing_state.get("snapshot", {})
    current_snapshot = build_snapshot(repo_root, config)
    changed_files, added_files, removed_files = diff_snapshots(previous_snapshot, current_snapshot)

    context = summarize_repo(repo_root, config)
    generated_docs = {
        "PROJECT_OVERVIEW.md": generate_project_overview(context, config),
        "CURRENT_PROGRESS.md": generate_current_progress(context, config, changed_files + added_files + removed_files),
        "DECISIONS_LOG.md": generate_decisions_log(context, config),
        "BUILD_LOG.md": generate_build_log(context, config, changed_files + added_files + removed_files),
        "CODE_MAP.md": generate_code_map(context, config, repo_root),
        "TASKS.md": generate_tasks(context, config),
        "OPEN_QUESTIONS.md": generate_open_questions(context, config, changed_files + added_files + removed_files),
    }

    updated_docs = ensure_export_docs(export_root, generated_docs)

    # Daily sync log depends on the current run result, so it is rendered after the other docs.
    destination = None
    copied_docs: List[str] = []
    skipped_copy = False
    if config.obsidian_vault_path.strip() and config.obsidian_project_folder.strip():
        vault_root = resolve_path(module_root, config.obsidian_vault_path)
        destination = vault_root / config.obsidian_project_folder
        try:
            copied_docs = mirror_to_vault(
                export_root,
                vault_root,
                destination,
                [*generated_docs.keys(), "DAILY_SYNC_LOG.md"],
                config.vault_note_prefix,
            )
        except Exception as exc:  # noqa: BLE001
            skipped_copy = True
            message = f"Exports updated, but vault mirror failed: {exc}"
            final_history = [
                {
                    "timestamp": datetime.now(timezone.utc).astimezone().strftime("%Y-%m-%d %H:%M:%S %Z"),
                    "status": "warning",
                    "message": message,
                    "changed_files": changed_files,
                    "updated_docs": updated_docs,
                    "copied_docs": copied_docs,
                }
            ] + list(existing_state.get("history", []))
            state = {"snapshot": current_snapshot, "history": final_history[: config.history_limit]}
            save_sync_state(state_path, state)
            daily_log = update_daily_sync_log(
                state["history"],
                config,
                SyncResult(
                    changed_files=changed_files,
                    added_files=added_files,
                    removed_files=removed_files,
                    updated_docs=updated_docs,
                    copied_docs=copied_docs,
                    skipped_copy=skipped_copy,
                    status="warning",
                    message=message,
                ),
                repo_root,
                destination,
            )
            if write_text_if_changed(export_root / "DAILY_SYNC_LOG.md", daily_log):
                updated_docs.append("DAILY_SYNC_LOG.md")
            return SyncResult(
                changed_files=changed_files,
                added_files=added_files,
                removed_files=removed_files,
                updated_docs=updated_docs,
                copied_docs=copied_docs,
                skipped_copy=skipped_copy,
                status="warning",
                message=message,
            )
    else:
        skipped_copy = True

    message = (
        f"Updated {len(updated_docs)} export docs. "
        f"Changed watched source files: {len(changed_files)}."
    )
    if skipped_copy:
        message += " Vault mirror skipped because destination was not fully configured."
    else:
        message += f" Copied {len(copied_docs)} docs to the configured vault."

    state = {
        "snapshot": current_snapshot,
        "history": [
            {
                "timestamp": datetime.now(timezone.utc).astimezone().strftime("%Y-%m-%d %H:%M:%S %Z"),
                "status": "success" if not skipped_copy else "info",
                "message": message,
                "changed_files": changed_files,
                "updated_docs": updated_docs,
                "copied_docs": copied_docs,
            }
        ]
        + list(existing_state.get("history", [])),
    }
    state["history"] = state["history"][: config.history_limit]
    save_sync_state(state_path, state)

    # Rewrite the daily sync log now that the final run summary is known.
    daily_log = update_daily_sync_log(
        state["history"],
        config,
        SyncResult(
            changed_files=changed_files,
            added_files=added_files,
            removed_files=removed_files,
            updated_docs=updated_docs,
            copied_docs=copied_docs,
            skipped_copy=skipped_copy,
            status="success" if not skipped_copy else "info",
            message=message,
        ),
        repo_root,
        destination,
    )
    if write_text_if_changed(daily_path, daily_log):
        updated_docs.append("DAILY_SYNC_LOG.md")

    return SyncResult(
        changed_files=changed_files,
        added_files=added_files,
        removed_files=removed_files,
        updated_docs=updated_docs,
        copied_docs=copied_docs,
        skipped_copy=skipped_copy,
        status="success" if not skipped_copy else "info",
        message=message,
    )


def watch_loop(config_path: Path, interval_seconds: int | None = None) -> int:
    module_root = config_path.parent
    config = load_config(config_path)
    repo_root = resolve_path(module_root, config.source_repo_path)
    poll_interval = interval_seconds or max(2, config.sync_interval_seconds)
    state_path = module_root / ".sync_state.json"
    last_snapshot = load_sync_state(state_path).get("snapshot", {})
    print(f"Watching {repo_root} every {poll_interval}s. Press Ctrl+C to stop.")
    while True:
        current_snapshot = build_snapshot(repo_root, config)
        changed, added, removed = diff_snapshots(last_snapshot, current_snapshot)
        if changed or added or removed:
            print(
                f"Change detected: {len(changed)} modified, {len(added)} added, {len(removed)} removed. Running sync..."
            )
            result = run_sync(config_path)
            print(result.message)
            last_snapshot = load_sync_state(state_path).get("snapshot", current_snapshot)
        time.sleep(poll_interval)


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Generate and sync Obsidian/Omega OS docs.")
    parser.add_argument("command", choices=["sync", "watch"], help="Run a one-time sync or keep watching.")
    parser.add_argument("--config", default=None, help="Path to obsidian_sync_config.json")
    parser.add_argument("--interval", type=int, default=None, help="Watcher polling interval in seconds")
    args = parser.parse_args(argv)

    script_dir = Path(__file__).resolve().parent
    module_root = script_dir.parent
    config_path = Path(args.config).resolve() if args.config else module_root / "obsidian_sync_config.json"

    if args.command == "sync":
        result = run_sync(config_path)
        print(result.message)
        print("Updated docs:")
        for doc in result.updated_docs:
            print(f" - {doc}")
        if result.copied_docs:
            print("Copied docs:")
            for doc in result.copied_docs:
                print(f" - {doc}")
        return 0

    if args.command == "watch":
        try:
            return watch_loop(config_path, args.interval)
        except KeyboardInterrupt:
            print("Watcher stopped.")
            return 0

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
