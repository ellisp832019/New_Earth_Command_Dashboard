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
        export_docs=dedupe_preserve_order(
            raw.get(
                "export_docs",
                [
                    "START_HERE.md",
                    "INDEX.md",
                    "DOC_REGISTRY.md",
                    "PROJECT_GRAPH.md",
                    "PROJECT_MAP.md",
                    "MODULE_STATUS.md",
                    "MODULE_RELATIONS.md",
                    "PROJECT_OVERVIEW.md",
                    "CURRENT_PROGRESS.md",
                    "CURRENT_STATE.md",
                    "ARCHITECTURE.md",
                    "ROADMAP.md",
                    "MILESTONE_SUMMARIES.md",
                    "CHANGE_INTELLIGENCE.md",
                    "RISK_TRACKER.md",
                    "DECISIONS.md",
                    "DECISIONS_LOG.md",
                    "BUILD_LOG.md",
                    "BUILD_LOG_SUMMARY.md",
                    "CODE_MAP.md",
                    "TASKS.md",
                    "OPEN_QUESTIONS.md",
                    "WEEKLY_REPORT.md",
                    "FULL_BUILD_HISTORY.md",
                    "DAILY_SYNC_LOG.md",
                ],
            )
        ),
        watched_paths=dedupe_preserve_order(
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
        watched_file_patterns=dedupe_preserve_order(
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
        ignore_paths=dedupe_preserve_order(
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


def dedupe_preserve_order(items: Sequence[str]) -> List[str]:
    seen = set()
    result = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        result.append(item)
    return result


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


def parse_full_commit_history(repo_root: Path) -> List[Tuple[str, str, str]]:
    try:
        result = subprocess.run(
            ["git", "log", "--reverse", "--date=short", "--pretty=format:%ad|%h|%s"],
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


def top_level_path(path: str) -> str:
    parts = Path(path).parts
    if not parts:
        return path
    if len(parts) == 1:
        return parts[0]
    return parts[0]


def commit_phase(subject: str) -> str:
    normalized = subject.lower()
    phase_rules = [
        ("Obsidian Sync And Documentation", ["obsidian", "sync", "export", "history", "index", "registry"]),
        ("Knowledge And Meetings", ["knowledge", "meeting", "bundle", "extraction", "library", "transcript"]),
        ("Treasury And Asset Intelligence", ["treasury", "asset", "qr", "inventory", "capture", "omega os", "folder health", "backup"]),
        ("Voice And Interaction", ["voice", "assistant", "wake", "briefing", "wizard", "dock", "thread"]),
        ("Foundation And Dashboard", ["shell", "database", "seed", "dashboard", "planner", "task", "journal", "content", "business", "wellbeing", "inbox", "settings"]),
        ("Calm UI And Refinement", ["calm", "soften", "ground", "polish", "spacing", "copy", "wording", "component"]),
    ]
    for label, keywords in phase_rules:
        if any(keyword in normalized for keyword in keywords):
            return label
    return "General Progress"


def build_milestone_groups(commits: Sequence[Tuple[str, str, str]]) -> List[Tuple[str, List[Tuple[str, str, str]]]]:
    groups: Dict[str, List[Tuple[str, str, str]]] = {}
    for date, sha, subject in commits:
        groups.setdefault(commit_phase(subject), []).append((date, sha, subject))

    ordered_labels = [
        "Foundation And Dashboard",
        "Voice And Interaction",
        "Calm UI And Refinement",
        "Treasury And Asset Intelligence",
        "Knowledge And Meetings",
        "Obsidian Sync And Documentation",
        "General Progress",
    ]
    ordered_groups = [(label, groups[label]) for label in ordered_labels if label in groups]
    return ordered_groups


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


def vault_note_name(config: SyncConfig, doc_name: str) -> str:
    stem = Path(doc_name).stem
    return f"{config.vault_note_prefix}{stem}" if config.vault_note_prefix else stem


def vault_link(config: SyncConfig, doc_name: str) -> str:
    return f"[[{vault_note_name(config, doc_name)}]]"


def generate_project_overview(context: Dict[str, object], config: SyncConfig) -> str:
    status = context["current_status"] or []

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
            "## Current Scope Guardrails",
            "- No login in V0.1.",
            "- No cloud sync in V0.1.",
            "- No live calendar, GitHub, WordPress, or MicroGrow integration yet.",
            "- No AI assistant in V0.1.",
            "",
            "## Summary Signal",
            render_list(status[:6]),
            "",
            f"- Branch: `{context['git']['branch'] or 'unknown'}`",
            f"- Current commit snapshot: `{context['git']['commit'] or 'unknown'}`",
            "",
            "## Related Docs",
            render_list(
                [
                    vault_link(config, "START_HERE.md"),
                    vault_link(config, "INDEX.md"),
                    vault_link(config, "DOC_REGISTRY.md"),
                    vault_link(config, "PROJECT_GRAPH.md"),
                    vault_link(config, "PROJECT_MAP.md"),
                    vault_link(config, "CURRENT_PROGRESS.md"),
                    vault_link(config, "CODE_MAP.md"),
                    vault_link(config, "MILESTONE_SUMMARIES.md"),
                    vault_link(config, "CHANGE_INTELLIGENCE.md"),
                    vault_link(config, "RISK_TRACKER.md"),
                    vault_link(config, "DECISIONS_LOG.md"),
                    vault_link(config, "BUILD_LOG.md"),
                    vault_link(config, "FULL_BUILD_HISTORY.md"),
                    vault_link(config, "DAILY_SYNC_LOG.md"),
                    "`README.md`",
                    "`docs/README.md`",
                    "`docs/roadmap/app_roadmap.md`",
                    "`docs/architecture/architecture_decisions.md`",
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Project Overview",
        "Handwritten notes can be added above or below the autogenerated block.",
        body,
    )


def generate_doc_registry(context: Dict[str, object], config: SyncConfig) -> str:
    rows = [
        ("START_HERE.md", "Entry point", "Human-friendly starting page and navigation hub.", "Canonical"),
        ("INDEX.md", "Entry point", "One-click vault landing page.", "Canonical"),
        ("DOC_REGISTRY.md", "Registry", "Maps the note families and avoids duplicate roles.", "Canonical"),
        ("PROJECT_GRAPH.md", "Graph", "Relationship map for folders, modules, notes, and workflows.", "Canonical"),
        ("PROJECT_MAP.md", "Operations", "Active module map for day-to-day navigation and handoffs.", "Canonical"),
        ("MODULE_STATUS.md", "Operations", "Quick lane status for active modules and handoffs.", "Canonical"),
        ("MODULE_RELATIONS.md", "Operations", "How active modules feed into and depend on each other.", "Canonical"),
        ("PROJECT_OVERVIEW.md", "Active state", "Project summary, purpose, and current branch signal.", "Canonical"),
        ("CURRENT_STATE.md", "Active state", "Detailed live status, risks, and next actions.", "Canonical"),
        ("CURRENT_PROGRESS.md", "Active state", "What works, what is incomplete, and the live sync signal.", "Canonical"),
        ("ARCHITECTURE.md", "Architecture", "System overview, dependencies, and integration points.", "Canonical"),
        ("CODE_MAP.md", "Architecture", "Folder map and data flow reference.", "Canonical"),
        ("ROADMAP.md", "Planning", "Near-term and longer-term direction.", "Canonical"),
        ("MILESTONE_SUMMARIES.md", "History", "Phase summaries across the project lifetime.", "Canonical"),
        ("CHANGE_INTELLIGENCE.md", "History", "What changed recently and where the churn is.", "Canonical"),
        ("RISK_TRACKER.md", "Operations", "Current blockers, severity, and next actions.", "Canonical"),
        ("TASKS.md", "Planning", "Immediate actions and what stays parked.", "Canonical"),
        ("DECISIONS.md", "Reference", "Short decision snapshot for quick scanning.", "Supporting"),
        ("DECISIONS_LOG.md", "Reference", "Detailed decision record and open decisions.", "Canonical"),
        ("BUILD_LOG.md", "Logs", "Current build snapshot and latest progress.", "Canonical"),
        ("BUILD_LOG_SUMMARY.md", "Logs", "Short build summary for quick reading.", "Supporting"),
        ("FULL_BUILD_HISTORY.md", "Archive", "Full chronological project history from git.", "Canonical"),
        ("WEEKLY_REPORT.md", "Reporting", "Weekly wins, blockers, risks, and summary.", "Canonical"),
        ("OPEN_QUESTIONS.md", "Planning", "Unresolved questions and TODO markers.", "Canonical"),
        ("DAILY_SYNC_LOG.md", "Operations", "Append-only sync history.", "Canonical"),
    ]

    body = "\n".join(
        [
            "## Why This Exists",
            "- The sync exports intentionally include both live notes and historical notes.",
            "- This registry makes the note roles explicit so the vault does not drift into duplicate-purpose files.",
            "- When two notes cover the same theme, one is the canonical note and the other is clearly marked as supporting or summary only.",
            "",
            "## Canonical Note Registry",
            render_table([("Note", "Family", "Purpose", "Role")] + rows),
            "",
            "## Duplicate Prevention Rules",
            "- Keep one canonical note per role.",
            "- Use supporting notes only for summaries or shortcuts back to the canonical note.",
            "- If a new note overlaps an existing one, update the registry first.",
            "",
            "## Read Order",
            render_list(
                [
                    vault_link(config, "START_HERE.md"),
                    vault_link(config, "INDEX.md"),
                    vault_link(config, "DOC_REGISTRY.md"),
                    vault_link(config, "PROJECT_GRAPH.md"),
                    vault_link(config, "PROJECT_MAP.md"),
                    vault_link(config, "MODULE_STATUS.md"),
                    vault_link(config, "MODULE_RELATIONS.md"),
                    vault_link(config, "PROJECT_OVERVIEW.md"),
                    vault_link(config, "CURRENT_STATE.md"),
                    vault_link(config, "BUILD_LOG.md"),
                    vault_link(config, "FULL_BUILD_HISTORY.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Document Registry",
        "Canonical note map for the Obsidian export set.",
        body,
    )


def generate_start_here(context: Dict[str, object], config: SyncConfig) -> str:
    focus = context["roadmap_immediate"] or context["next_actions"] or [
        "Finish the current local-first slice.",
        "Keep the sync notes calm and easy to navigate.",
        "Avoid widening scope before the current slice is stable.",
    ]
    current_signal = context["git"]["last_commit"] or context["git"]["commit"] or "unknown"

    body = "\n".join(
        [
            "## What This Is",
            f"- {config.project_name} is the local-first project memory and operating hub for New Earth.",
            "- This page is the human-friendly starting point.",
            "- Use it when you want the shortest path to the live state and the most useful follow-up notes.",
            "",
            "## Where To Begin",
            render_list(
                [
                    vault_link(config, "INDEX.md"),
                    vault_link(config, "DOC_REGISTRY.md"),
                    vault_link(config, "PROJECT_GRAPH.md"),
                    vault_link(config, "PROJECT_MAP.md"),
                    vault_link(config, "MODULE_STATUS.md"),
                    vault_link(config, "PROJECT_OVERVIEW.md"),
                    vault_link(config, "CURRENT_STATE.md"),
                    vault_link(config, "BUILD_LOG.md"),
                    vault_link(config, "FULL_BUILD_HISTORY.md"),
                ]
            ),
            "",
            "## What Changed Most Recently",
            f"- Latest commit signal: `{current_signal}`",
            f"- Branch: `{context['git']['branch'] or 'unknown'}`",
            "",
            "## Current Focus",
            render_list(focus),
            "",
            "## Safe Working Rules",
            "- Keep handwritten notes outside the autogenerated block.",
            "- Use the registry before adding new export notes.",
            "- Keep one note per role so the vault stays easy to scan.",
            "",
            "## Fast Links",
            render_list(
                [
                    vault_link(config, "MILESTONE_SUMMARIES.md"),
                    vault_link(config, "CHANGE_INTELLIGENCE.md"),
                    vault_link(config, "RISK_TRACKER.md"),
                    vault_link(config, "PROJECT_GRAPH.md"),
                    vault_link(config, "PROJECT_MAP.md"),
                    vault_link(config, "MODULE_STATUS.md"),
                    vault_link(config, "MODULE_RELATIONS.md"),
                    vault_link(config, "TASKS.md"),
                    vault_link(config, "OPEN_QUESTIONS.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Start Here",
        "Human-friendly entry point for the Obsidian vault.",
        body,
    )


def generate_project_graph(context: Dict[str, object], config: SyncConfig, repo_root: Path) -> str:
    feature_root = repo_root / "lib" / "features"
    feature_groups = []
    if feature_root.exists():
        for child in sorted([p for p in feature_root.iterdir() if p.is_dir()], key=lambda p: p.name):
            file_count = sum(1 for item in child.rglob("*") if item.is_file())
            feature_groups.append((f"`lib/features/{child.name}/`", f"{file_count} tracked files"))

    folder_rows = [
        ("`lib/`", "Flutter features, shared services, and app UI.", "Primary app surface"),
        ("`docs/`", "Roadmaps, FSD docs, architecture notes, and guides.", "Project memory and spec layer"),
        ("`modules/`", "Support modules like meeting system and repo tooling.", "Shared operational modules"),
        ("`assets/`", "Screenshots, guides, and visual support files.", "Reference material"),
        ("`tools/`", "Desktop helpers and small local scripts.", "Utility layer"),
        ("`config/`", "Local configuration and path mapping.", "Environment glue"),
        ("`obsidian_sync/`", "Sync scripts, exports, templates, and docs.", "Obsidian integration"),
    ]
    if feature_groups:
        folder_rows.extend((name, desc, "Feature slice") for name, desc in feature_groups[:12])

    note_rows = [
        ("START_HERE.md", "Human entry point", "The first note to open in the vault."),
        ("INDEX.md", "Technical hub", "The menu of canonical notes and logs."),
        ("DOC_REGISTRY.md", "Canonical map", "The role map that prevents duplicate-purpose notes."),
        ("PROJECT_OVERVIEW.md", "Project summary", "What the project is and where it is heading."),
        ("CURRENT_STATE.md", "Live state", "The most detailed active status note."),
        ("CURRENT_PROGRESS.md", "Progress signal", "What works, what is incomplete, and the sync signal."),
        ("MILESTONE_SUMMARIES.md", "Phase view", "Grouped story of the project life cycle."),
        ("CHANGE_INTELLIGENCE.md", "Churn view", "What changed recently and where it happened."),
        ("RISK_TRACKER.md", "Risk view", "Current blockers and watch items."),
        ("BUILD_LOG.md", "Snapshot log", "Current build picture and latest progress."),
        ("FULL_BUILD_HISTORY.md", "Archive", "The full chronological project history."),
    ]

    flow_rows = [
        ("Repo source", "Code, docs, and task files in this repository."),
        ("Sync engine", "Generates Markdown and resolves canonical note roles."),
        ("Export folder", "Staging area under `obsidian_sync/exports`."),
        ("Vault mirror", "Copies notes into the Omega vault project folder."),
        ("Obsidian view", "Human reading, linking, and handwritten notes."),
    ]

    body = "\n".join(
        [
            "## What This Graph Shows",
            "- The project graph is a relationship map, not another status note.",
            "- It shows how the code folders, generated notes, and local vault all connect.",
            "",
            "## Folder Graph",
            render_table([("Folder", "Purpose", "Relationship")] + folder_rows),
            "",
            "## Note Graph",
            render_table([("Note", "Role", "Relationship")] + note_rows),
            "",
            "## Local-First Flow",
            render_list([f"{left} -> {right}" for left, right in flow_rows]),
            "",
            "## Dependency Spine",
            render_list(
                [
                    "Flutter and Material 3 provide the app shell.",
                    "`go_router` shapes the navigation graph.",
                    "`flutter_riverpod` manages state when it is needed.",
                    "`drift` and SQLite store local project data.",
                    "The Obsidian sync module turns repo content into vault notes.",
                ]
            ),
            "",
            "## Relationship Notes",
            render_list(
                [
                    "The registry defines which note owns each role.",
                    "The start page points humans to the shortest path into the vault.",
                    "The index keeps the canonical note set easy to scan.",
                    "The graph note explains how the pieces connect without repeating the content of the other notes.",
                ]
            ),
            "",
            "## Related Docs",
            render_list(
                [
                    vault_link(config, "START_HERE.md"),
                    vault_link(config, "INDEX.md"),
                    vault_link(config, "DOC_REGISTRY.md"),
                    vault_link(config, "MODULE_STATUS.md"),
                    vault_link(config, "PROJECT_MAP.md"),
                    vault_link(config, "MODULE_RELATIONS.md"),
                    vault_link(config, "PROJECT_OVERVIEW.md"),
                    vault_link(config, "CODE_MAP.md"),
                    vault_link(config, "ARCHITECTURE.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Project Graph",
        "Relationship map for the repo, notes, and vault flow.",
        body,
    )


def generate_project_map(context: Dict[str, object], config: SyncConfig, repo_root: Path) -> str:
    feature_root = repo_root / "lib" / "features"
    modules = []
    if feature_root.exists():
        for child in sorted([p for p in feature_root.iterdir() if p.is_dir()], key=lambda p: p.name):
            file_count = sum(1 for item in child.rglob("*") if item.is_file())
            label = child.name.replace("_", " ").title()
            modules.append((label, f"`lib/features/{child.name}/`", f"{file_count} tracked files"))

    operational_lanes = [
        ("Dashboard", "`lib/features/dashboard/`", "Live overview, quick capture, and entry points."),
        ("Projects", "`lib/features/project_intelligence/`", "Project context, capture, and related knowledge."),
        ("Tasks", "`lib/features/planner/`", "Task review, carry-forward, and Top 3 flow."),
        ("Treasury", "`lib/features/assets/`", "Treasury, assets, QR, inventory, and workspace operations."),
        ("Knowledge", "`lib/features/knowledge_library/`", "Knowledge library, extraction, and file handling."),
        ("Meetings", "`lib/features/meeting_system/`", "Meeting bundles, transcript import, and review flow."),
        ("Voice", "`lib/features/more/`", "Voice assistant entry points and shared session flow."),
        ("Obsidian Sync", "`obsidian_sync/`", "Project memory exports and vault mirroring."),
    ]

    next_moves = context["roadmap_immediate"] or context["next_actions"] or [
        "Finish the current local-first slice.",
        "Keep the vault notes easy to scan.",
        "Keep the operational focus on one slice at a time.",
    ]

    body = "\n".join(
        [
            "## What This Map Is For",
            "- Use this note when you want to understand the active modules, not just the file graph.",
            "- It is the operational bridge between the app, the docs, and the Obsidian memory layer.",
            "",
            "## Active Module Lanes",
            render_table([("Module", "Path", "Why It Matters")] + operational_lanes),
            "",
            "## Feature Inventory",
            render_table(
                [("Feature", "Path", "Size Signal")] + modules[:12] if modules else [("Feature", "Path", "Size Signal")]
            ),
            "",
            "## What To Touch For Common Jobs",
            render_list(
                [
                    "Dashboard and capture work -> `lib/features/dashboard/`",
                    "Task review and carry-forward -> `lib/features/planner/`",
                    "Treasury, assets, and QR/print -> `lib/features/assets/`",
                    "Knowledge library and extraction -> `lib/features/knowledge_library/`",
                    "Meeting bundles and transcript handling -> `lib/features/meeting_system/`",
                    "Vault note generation and sync -> `obsidian_sync/`",
                ]
            ),
            "",
            "## Active Next Moves",
            render_list(next_moves),
            "",
            "## Operational Rules",
            "- Treat each module lane as a handoff point, not a duplicate note family.",
            "- If a lane changes meaningfully, update the graph and registry together.",
            "- Keep the map focused on active work, not the full archive.",
            "",
            "## Related Docs",
            render_list(
                [
                    vault_link(config, "START_HERE.md"),
                    vault_link(config, "INDEX.md"),
                    vault_link(config, "DOC_REGISTRY.md"),
                    vault_link(config, "PROJECT_GRAPH.md"),
                    vault_link(config, "MODULE_STATUS.md"),
                    vault_link(config, "PROJECT_OVERVIEW.md"),
                    vault_link(config, "CURRENT_STATE.md"),
                    vault_link(config, "TASKS.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Project Map",
        "Operational map for active modules and work handoffs.",
        body,
    )


def generate_module_status(context: Dict[str, object], config: SyncConfig) -> str:
    lanes = [
        ("Dashboard", "Stable", "Core dashboard flows are in place and should change slowly.", "Keep it calm and avoid broad rewrites."),
        ("Projects", "Active", "Project context and related knowledge are still being refined.", "Finish the next review-first polish pass."),
        ("Tasks", "Stable", "Task review, carry-forward, and Top 3 support are established.", "Only adjust when the task flow itself changes."),
        ("Treasury", "Active", "Treasury, assets, QR, and inventory remain a live focus area.", "Continue treasury navigation polish and asset hardening."),
        ("Knowledge", "Active", "Knowledge library and extraction flows are live and still being refined.", "Keep extraction and file handling resilient."),
        ("Meetings", "Active", "Meeting bundle workflows are present and cross-linked.", "Keep review and export paths reliable."),
        ("Voice", "Parked", "The voice slice is intentionally parked after the completed bridge work.", "Do not widen scope until the current active slice settles."),
        ("Obsidian Sync", "Stable", "Sync, registry, graph, map, and history notes are now established.", "Maintain canonical note roles and update links together."),
    ]

    current_focus = context["roadmap_immediate"] or context["next_actions"] or [
        "Finish the current local-first slice.",
        "Keep module handoffs clear.",
        "Avoid widening scope before the active lane is stable.",
    ]

    body = "\n".join(
        [
            "## Lane Status",
            render_table([("Lane", "State", "Why", "Next Action")] + lanes),
            "",
            "## Reading Guide",
            "- Stable means the lane should only change when the underlying workflow changes.",
            "- Active means the lane is still moving and should be reviewed before broad edits.",
            "- Parked means the lane is intentionally held for now and should not be expanded casually.",
            "",
            "## Current Focus",
            render_list(current_focus),
            "",
            "## Cross-Checks",
            render_list(
                [
                    vault_link(config, "PROJECT_MAP.md"),
                    vault_link(config, "PROJECT_GRAPH.md"),
                    vault_link(config, "MODULE_RELATIONS.md"),
                    vault_link(config, "CURRENT_STATE.md"),
                    vault_link(config, "TASKS.md"),
                ]
            ),
            "",
            "## Operating Rule",
            "- If a lane moves from active to stable or parked, update this note first and then update the hub links.",
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Module Status",
        "Operational lane status for active modules and handoffs.",
        body,
    )


def generate_module_relations(context: Dict[str, object], config: SyncConfig) -> str:
    relations = [
        ("Dashboard", "Projects, Tasks, Treasury", "Capture and overview work often starts here and routes outward."),
        ("Projects", "Dashboard, Knowledge, Meetings", "Project context gathers evidence and links to follow-up workflows."),
        ("Tasks", "Dashboard, Projects, Treasury", "Task review turns captured work into the next practical action."),
        ("Treasury", "Projects, Tasks, Assets", "Treasury work often depends on project context and leads into asset handling."),
        ("Knowledge", "Projects, Meetings, Obsidian Sync", "Knowledge extraction feeds back into project memory and vault notes."),
        ("Meetings", "Projects, Tasks, Knowledge", "Meeting bundles create inputs for follow-up tasks and archive notes."),
        ("Voice", "Dashboard, Projects, Tasks", "Voice capture is a front door to other lanes, but remains parked for now."),
        ("Obsidian Sync", "All lanes", "Exports and vault notes depend on the rest of the repo being kept in sync."),
    ]

    dependency_notes = [
        "If Dashboard changes, re-check Projects and Tasks because they share the user-facing handoff path.",
        "If Treasury changes, verify the asset and QR workflows before the lane is considered stable.",
        "If Knowledge changes, confirm that extraction and sync notes still line up with the source files.",
        "If Meetings changes, confirm that task carry-forward and project references still resolve cleanly.",
        "If Obsidian Sync changes, update the registry, graph, map, and status notes together.",
    ]

    body = "\n".join(
        [
            "## Why This Exists",
            "- Use this note when you want to see how module changes travel across the system.",
            "- It shows upstream and downstream relationships rather than a simple lane list.",
            "",
            "## Module Relationships",
            render_table([("Module", "Feeds Into", "Relation")] + relations),
            "",
            "## Change Handoffs",
            render_list(dependency_notes),
            "",
            "## Reading Guide",
            "- Upstream means the module usually supplies context or input.",
            "- Downstream means the module often receives follow-up work or generated output.",
            "- Shared means the modules should be reviewed together when one changes.",
            "",
            "## Cross-Checks",
            render_list(
                [
                    vault_link(config, "PROJECT_MAP.md"),
                    vault_link(config, "MODULE_STATUS.md"),
                    vault_link(config, "PROJECT_GRAPH.md"),
                    vault_link(config, "CURRENT_STATE.md"),
                ]
            ),
            "",
            "## Operating Rule",
            "- When one lane changes, scan the related lanes before calling the slice complete.",
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Module Relations",
        "Relationships and handoffs between the active module lanes.",
        body,
    )


def generate_index(context: Dict[str, object], config: SyncConfig) -> str:
    current_docs = [
        "DOC_REGISTRY.md",
        "PROJECT_GRAPH.md",
        "PROJECT_MAP.md",
        "MODULE_STATUS.md",
        "MODULE_RELATIONS.md",
        "PROJECT_OVERVIEW.md",
        "CURRENT_STATE.md",
        "CURRENT_PROGRESS.md",
        "ARCHITECTURE.md",
        "CODE_MAP.md",
        "ROADMAP.md",
        "MILESTONE_SUMMARIES.md",
        "CHANGE_INTELLIGENCE.md",
        "RISK_TRACKER.md",
        "TASKS.md",
    ]
    logs = [
        "DECISIONS.md",
        "DECISIONS_LOG.md",
        "BUILD_LOG.md",
        "BUILD_LOG_SUMMARY.md",
        "FULL_BUILD_HISTORY.md",
        "WEEKLY_REPORT.md",
        "OPEN_QUESTIONS.md",
        "DAILY_SYNC_LOG.md",
    ]
    body = "\n".join(
        [
            "## Start Here",
            render_list([vault_link(config, "START_HERE.md")]),
            "",
            "## Canonical Notes",
            render_list([vault_link(config, doc) for doc in current_docs]),
            "",
            "## Logs And History",
            render_list([vault_link(config, doc) for doc in logs]),
            "",
            "## Current Focus",
            render_list(
                [
                    "Finish the voice polish slice.",
                    "Harden asset intelligence and QR/print flows.",
                    "Keep AI parked until the local-first voice path is stable.",
                ]
            ),
            "",
            "## Vault Layout",
            f"- Vault root: `{config.obsidian_vault_path}`",
            f"- Project folder: `{config.obsidian_project_folder}`",
            f"- Note prefix: `{config.vault_note_prefix}`",
            "",
            "## How To Use",
            "- Open this note first.",
            "- Use the start here page for a quicker human-friendly landing page.",
            "- Use the document registry to avoid repeating the same note role in multiple places.",
            "- Jump to the live state or the build history from here.",
            "- Keep handwritten notes outside the autogenerated block.",
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Index",
        "This is the Obsidian entry point for the project.",
        body,
    )


def generate_current_progress(context: Dict[str, object], config: SyncConfig, changed_files: Sequence[str]) -> str:
    next_actions = context["next_actions"] or context["roadmap_immediate"] or [
        "Finish the current local-first slice.",
        "Keep the docs and build notes aligned.",
        "Avoid widening scope before the current slice is stable.",
    ]
    risks = bullet_items(context["readme"], "Current Risks") or bullet_items(context["roadmap"], "Working Principles")
    if not risks:
        risks = [
            "The app surface is broad, so routing and docs can drift if too many slices move at once.",
            "Windows-specific voice dependencies can vary by machine.",
            "Local file paths and asset/config assumptions need to stay stable.",
        ]
    sync_signal = [
        f"Changed source files in this run: {len(changed_files)}",
        f"Branch: `{context['git']['branch'] or 'unknown'}`",
        f"Commit snapshot: `{context['git']['commit'] or 'unknown'}`",
    ]

    body = "\n".join(
        [
            "## Live Sync Snapshot",
            render_list(sync_signal),
            "",
            "## Current Risks",
            render_list(risks),
            "",
            "## Next Priority Actions",
            render_list(next_actions),
            "",
            "## What This Note Is For",
            "- Use this as the quick sync pulse for the current run.",
            "- The fuller live state lives in `CURRENT_STATE.md`.",
            "- The rollout plan lives in `ROADMAP.md` and `TASKS.md`.",
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


def generate_decisions_summary(context: Dict[str, object], config: SyncConfig) -> str:
    key_decisions = [
        "Local-first and offline-first for V0.1.",
        "Use a feature-based Flutter structure.",
        "Use go_router for navigation.",
        "Use Riverpod when state is needed.",
        "Keep the dashboard calm and review-first.",
    ]

    body = "\n".join(
        [
            "## Key Technical Decisions",
            render_list(key_decisions),
            "",
            "## Why They Matter",
            "- These decisions keep the app local, readable, and easy to extend.",
            "- They also keep the Obsidian export set understandable by separating the summary from the long-form decision log.",
            "",
            "## See Also",
            render_list(
                [
                    vault_link(config, "DECISIONS_LOG.md"),
                    vault_link(config, "INDEX.md"),
                    vault_link(config, "DOC_REGISTRY.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Decisions",
        "Short decision summary for quick scanning.",
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
            "",
            "## Archive Links",
            render_list(
                [
                    vault_link(config, "DOC_REGISTRY.md"),
                    vault_link(config, "FULL_BUILD_HISTORY.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Build Log",
        "This note tracks the build and sync picture for the current repo.",
        body,
    )


def generate_build_log_summary(context: Dict[str, object], config: SyncConfig) -> str:
    recent_commits = context["recent_commits"][:3]
    latest_commit = context["git"]["last_commit"]
    devlog_summary = context["devlog_summary"] or "No development log summary found."
    commit_points = [
        f"Latest commit snapshot: `{latest_commit}`" if latest_commit else "Latest commit snapshot unavailable.",
    ]
    commit_points.extend([f"`{sha}` {subject} ({date})" for date, sha, subject in recent_commits])

    body = "\n".join(
        [
            "## Latest Summary",
            devlog_summary,
            "",
            "## Snapshot",
            render_list(commit_points),
            "",
            "## See Also",
            render_list(
                [
                    vault_link(config, "BUILD_LOG.md"),
                    vault_link(config, "FULL_BUILD_HISTORY.md"),
                    vault_link(config, "DOC_REGISTRY.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Build Log Summary",
        "Short build summary for quick reading.",
        body,
    )


def generate_milestone_summaries(context: Dict[str, object], config: SyncConfig, repo_root: Path) -> str:
    commits = parse_full_commit_history(repo_root)
    if not commits:
        body = "\n".join(
            [
                "## Summary",
                "- Git history is not available in this environment.",
                "",
                "## Related Notes",
                render_list(
                    [
                        vault_link(config, "FULL_BUILD_HISTORY.md"),
                        vault_link(config, "BUILD_LOG.md"),
                    ]
                ),
            ]
        ).strip()
        return heading_block(
            f"{config.project_name} Milestone Summaries",
            "Phase summaries across the project lifetime.",
            body,
        )

    phase_summaries = {
        "Foundation And Dashboard": "The app shell, local data model, and daily dashboard loops came together first.",
        "Voice And Interaction": "The voice bridge, assistant flow, and wake/session behaviour became a real working slice.",
        "Calm UI And Refinement": "The interface and wording were smoothed to reduce friction and overwhelm.",
        "Treasury And Asset Intelligence": "Treasury, asset, QR, inventory, and Omega OS operational tooling expanded quickly.",
        "Knowledge And Meetings": "Knowledge library, extraction, meeting bundles, and cross-linking became first-class workflows.",
        "Obsidian Sync And Documentation": "The project memory layer was made portable and easier to maintain inside Obsidian.",
        "General Progress": "Mixed improvements that do not fit a single theme but still moved the repo forward.",
    }
    grouped = build_milestone_groups(commits)
    sections = [
        "## How To Read This",
        "- This is a phase summary note, not the full archive.",
        "- Use `FULL_BUILD_HISTORY.md` when you want every commit.",
        "- Use this note when you want the story of the project in a compact form.",
        "",
    ]

    for phase, items in grouped:
        start_date = items[0][0]
        end_date = items[-1][0]
        anchors = [f"`{sha}` {subject} ({date})" for date, sha, subject in items[:6]]
        sections.extend(
            [
                f"## {phase}",
                f"- Date range: {start_date} to {end_date}",
                f"- Commit count: {len(items)}",
                f"- Summary: {phase_summaries.get(phase, 'Project changes in this phase supported the broader local-first build.')}",
                "",
                "### Anchor Commits",
                render_list(anchors),
                "",
            ]
        )

    sections.extend(
        [
            "## Current Takeaway",
            "- The repository has moved from app foundation into long-lived operational tooling, knowledge, and project memory.",
            "- The next improvements should stay focused on clarity, traceability, and a single obvious place to start.",
        ]
    )

    return heading_block(
        f"{config.project_name} Milestone Summaries",
        "Phase summaries across the project lifetime.",
        "\n".join(sections).strip(),
    )


def generate_change_intelligence(
    context: Dict[str, object],
    config: SyncConfig,
    changed_files: Sequence[str],
    added_files: Sequence[str],
    removed_files: Sequence[str],
) -> str:
    all_changes = list(changed_files) + list(added_files) + list(removed_files)
    total_changes = len(all_changes)
    top_level_counts: Dict[str, int] = {}
    for file_path in all_changes:
        root = top_level_path(file_path)
        top_level_counts[root] = top_level_counts.get(root, 0) + 1
    top_areas = sorted(top_level_counts.items(), key=lambda item: (-item[1], item[0]))[:8]
    recent_commits = context["recent_commits"][:6]

    body = "\n".join(
        [
            "## Since Last Sync",
            f"- Changed files: {len(changed_files)}",
            f"- Added files: {len(added_files)}",
            f"- Removed files: {len(removed_files)}",
            f"- Total file deltas tracked: {total_changes}",
            "",
            "## Change Hotspots",
            render_list([f"{area}: {count}" for area, count in top_areas] if top_areas else ["No file deltas detected in the watched scope."]),
            "",
            "## Recent Commit Signal",
            render_list([f"`{sha}` {subject} ({date})" for date, sha, subject in recent_commits]),
            "",
            "## What To Watch Next",
            render_list(
                [
                    "If voice, wake handling, and routing change together, review those paths as one slice.",
                    "If docs start changing without source changes, check whether the vault registry needs a refresh.",
                    "If local asset or treasury folders move, verify the sync config and ignore paths.",
                ]
            ),
            "",
            "## Related Notes",
            render_list(
                [
                    vault_link(config, "RISK_TRACKER.md"),
                    vault_link(config, "BUILD_LOG.md"),
                    vault_link(config, "FULL_BUILD_HISTORY.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Change Intelligence",
        "What changed recently and where the churn is concentrated.",
        body,
    )


def generate_risk_tracker(context: Dict[str, object], config: SyncConfig) -> str:
    risks = bullet_items(context["readme"], "Current Risks")
    if not risks:
        risks = bullet_items(context["roadmap"], "Working Principles")
    if not risks:
        risks = [
            "The app surface is broad, so routing and docs can drift if too many slices move at once.",
            "Windows-specific voice dependencies can vary by machine.",
            "Local file paths and asset/config assumptions need to stay stable.",
        ]

    open_questions = bullet_items(context["ai_roadmap"], "Open Decisions")
    if not open_questions:
        open_questions = [
            "Which slice should come after voice polish?",
            "When should the AI adapter move beyond roadmap-only status?",
            "How much should the sync module be shared across downstream repos?",
        ]

    rows = []
    for risk in risks[:6]:
        normalized = risk.lower()
        if "voice" in normalized or "windows" in normalized:
            severity = "High"
        elif "routing" in normalized or "docs" in normalized or "file" in normalized:
            severity = "Medium"
        else:
            severity = "Low"
        rows.append(
            (
                severity,
                risk,
                "Review the affected slice before widening scope.",
            )
        )

    body = "\n".join(
        [
            "## Current Risks",
            render_table([("Severity", "Risk", "Next Action")] + rows),
            "",
            "## Open Questions",
            render_list(open_questions),
            "",
            "## Blocker Watch",
            render_list(
                [
                    "Keep voice, wake handling, and routing changes in the same review pass when possible.",
                    "Keep Obsidian export names canonical so the vault does not accumulate duplicate note roles.",
                    "Keep local path assumptions aligned between the repo and the Omega vault layout.",
                ]
            ),
            "",
            "## Related Notes",
            render_list(
                [
                    vault_link(config, "CHANGE_INTELLIGENCE.md"),
                    vault_link(config, "CURRENT_PROGRESS.md"),
                    vault_link(config, "OPEN_QUESTIONS.md"),
                ]
            ),
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Risk Tracker",
        "Live risk and blocker watch list.",
        body,
    )


def generate_full_build_history(context: Dict[str, object], config: SyncConfig, repo_root: Path) -> str:
    commits = parse_full_commit_history(repo_root)
    if not commits:
        history_body = "\n".join(
            [
                "## Scope",
                "- The repository history could not be read from git in this environment.",
                "",
                "## Notes",
                "- Use `BUILD_LOG.md` for the current snapshot until git history is available.",
            ]
        ).strip()
        return heading_block(
            f"{config.project_name} Full Build History",
            "Canonical long-form project history.",
            history_body,
        )

    grouped: Dict[str, List[Tuple[str, str]]] = {}
    for date, sha, subject in commits:
        grouped.setdefault(date, []).append((sha, subject))

    sections = [
        "## Scope",
        "- This note captures the project history from the repository timeline and the development log.",
        "- It is the canonical long-form archive for the entire project life cycle.",
        "",
        "## How To Read This",
        "- The log is chronological, oldest to newest.",
        "- Each date groups the commits from that period.",
        "- Supporting summaries live in `BUILD_LOG.md` and `BUILD_LOG_SUMMARY.md`.",
        "",
    ]

    for date in sorted(grouped):
        sections.append(f"## {date}")
        sections.extend([f"- `{sha}` {subject}" for sha, subject in grouped[date]])
        sections.append("")

    sections.extend(
        [
            "## Development Log Correlation",
            "- The development log in `docs/developer_guide/development_log.md` matches the major phases captured here.",
            "- If a detail is inferred from commit clusters, it is kept as a plain summary rather than overstated as a fact.",
            "",
            "## Notes",
            "- The timeline is complete as of the repository history available in this clone.",
            "- If more narrative detail is needed later, the next step is to mine commit diffs into a curated milestone story.",
        ]
    )

    return heading_block(
        f"{config.project_name} Full Build History",
        "Canonical long-form project history.",
        "\n".join(sections).strip(),
    )


def generate_code_map(context: Dict[str, object], config: SyncConfig) -> str:
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

    body = "\n".join(
        [
            "## Location Map",
            render_table([("Location", "Purpose")] + important_roots),
            "",
            "## What To Use This For",
            render_list(
                [
                    "Find the main source roots quickly.",
                    "Use the project map for feature lanes and the architecture note for system detail.",
                    "Jump to the right top-level area without reading the longer architecture note.",
                ]
            ),
            "",
            "## Related Docs",
            render_list(
                [
                    vault_link(config, "PROJECT_GRAPH.md"),
                    vault_link(config, "PROJECT_MAP.md"),
                    vault_link(config, "MODULE_STATUS.md"),
                    vault_link(config, "MODULE_RELATIONS.md"),
                    vault_link(config, "ARCHITECTURE.md"),
                    vault_link(config, "DOC_REGISTRY.md"),
                ]
            ),
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
    parked = context["roadmap_not_yet"] or [
        "Login.",
        "Cloud sync.",
        "Full AI assistant.",
        "Large UI redesigns.",
        "Broad architecture rewrites.",
    ]

    body = "\n".join(
        [
            "## Immediate Actions",
            render_list(immediate),
            "",
            "## Parked For Now",
            "These are useful later, but not the current focus:",
            "",
            render_list(parked),
            "",
            "## How To Use This Note",
            "- This is the short action note, not the roadmap.",
            "- If you want the 4 week and 3 month plan, open `ROADMAP.md`.",
            "- If you want the live sync pulse, open `CURRENT_PROGRESS.md`.",
        ]
    ).strip()
    return heading_block(
        f"{config.project_name} Tasks",
        "Short action list and parked work.",
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
        "START_HERE.md": generate_start_here(context, config),
        "INDEX.md": generate_index(context, config),
        "DOC_REGISTRY.md": generate_doc_registry(context, config),
        "PROJECT_GRAPH.md": generate_project_graph(context, config, repo_root),
        "PROJECT_MAP.md": generate_project_map(context, config, repo_root),
        "MODULE_STATUS.md": generate_module_status(context, config),
        "MODULE_RELATIONS.md": generate_module_relations(context, config),
        "PROJECT_OVERVIEW.md": generate_project_overview(context, config),
        "CURRENT_PROGRESS.md": generate_current_progress(context, config, changed_files + added_files + removed_files),
        "MILESTONE_SUMMARIES.md": generate_milestone_summaries(context, config, repo_root),
        "CHANGE_INTELLIGENCE.md": generate_change_intelligence(
            context,
            config,
            changed_files,
            added_files,
            removed_files,
        ),
        "RISK_TRACKER.md": generate_risk_tracker(context, config),
        "DECISIONS.md": generate_decisions_summary(context, config),
        "DECISIONS_LOG.md": generate_decisions_log(context, config),
        "BUILD_LOG.md": generate_build_log(context, config, changed_files + added_files + removed_files),
        "BUILD_LOG_SUMMARY.md": generate_build_log_summary(context, config),
        "CODE_MAP.md": generate_code_map(context, config),
        "TASKS.md": generate_tasks(context, config),
        "OPEN_QUESTIONS.md": generate_open_questions(context, config, changed_files + added_files + removed_files),
        "FULL_BUILD_HISTORY.md": generate_full_build_history(context, config, repo_root),
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
                [*config.export_docs],
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
