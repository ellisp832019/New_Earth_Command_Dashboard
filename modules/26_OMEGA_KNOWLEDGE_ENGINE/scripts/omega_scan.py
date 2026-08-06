#!/usr/bin/env python3
"""Omega Knowledge Engine v1 scanner.

Safe-by-default repository scanner. It indexes code and docs and creates
human-readable learning reports. It does not edit source files.
"""
from __future__ import annotations

import argparse
import ast
import json
import os
from pathlib import Path
from datetime import datetime

try:
    import yaml
except ImportError:
    yaml = None


def load_config(path: Path) -> dict:
    if yaml and path.exists():
        return yaml.safe_load(path.read_text(encoding="utf-8"))
    # Minimal fallback if PyYAML is not installed.
    return {
        "paths": {"repo_root": "..", "output_dir": "output", "obsidian_export_dir": "output/obsidian_export"},
        "scan": {
            "include_extensions": [".py", ".dart", ".cpp", ".c", ".h", ".hpp", ".ino", ".js", ".ts", ".md", ".yaml", ".yml", ".json"],
            "ignore_dirs": [".git", "build", "dist", "node_modules", ".venv", "venv", "vendor", "__pycache__", "output"],
            "max_file_size_kb": 512,
        },
    }


def should_ignore(path: Path, ignore_dirs: set[str]) -> bool:
    return any(part in ignore_dirs for part in path.parts)


def discover_python_symbols(path: Path) -> dict:
    try:
        tree = ast.parse(path.read_text(encoding="utf-8", errors="ignore"))
    except Exception:
        return {"functions": [], "classes": []}
    functions, classes = [], []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            functions.append(node.name)
        elif isinstance(node, ast.ClassDef):
            classes.append(node.name)
    return {"functions": functions, "classes": classes}


def simple_symbol_scan(text: str, ext: str) -> dict:
    functions, classes = [], []
    lines = text.splitlines()
    for line in lines:
        s = line.strip()
        if ext == ".dart" and (s.startswith("class ") or s.startswith("abstract class ")):
            classes.append(s.split("{")[0])
        if ext in {".cpp", ".c", ".h", ".hpp", ".ino", ".js", ".ts", ".tsx", ".jsx", ".dart"}:
            if "(" in s and ")" in s and not s.startswith(("//", "/*", "*", "if", "for", "while", "switch")):
                if len(functions) < 80:
                    functions.append(s[:160])
    return {"functions": functions, "classes": classes}


def scan_repo(repo_root: Path, cfg: dict) -> list[dict]:
    scan_cfg = cfg.get("scan", {})
    exts = set(scan_cfg.get("include_extensions", []))
    ignore_dirs = set(scan_cfg.get("ignore_dirs", []))
    max_bytes = int(scan_cfg.get("max_file_size_kb", 512)) * 1024
    records = []
    for path in repo_root.rglob("*"):
        if not path.is_file():
            continue
        if should_ignore(path.relative_to(repo_root), ignore_dirs):
            continue
        if path.suffix not in exts:
            continue
        try:
            size = path.stat().st_size
        except OSError:
            continue
        if size > max_bytes:
            continue
        rel = path.relative_to(repo_root).as_posix()
        text = path.read_text(encoding="utf-8", errors="ignore")
        if path.suffix == ".py":
            symbols = discover_python_symbols(path)
        else:
            symbols = simple_symbol_scan(text, path.suffix)
        records.append({
            "path": rel,
            "extension": path.suffix,
            "size_bytes": size,
            "line_count": len(text.splitlines()),
            "functions_or_signatures": symbols["functions"],
            "classes": symbols["classes"],
            "first_lines": text.splitlines()[:5],
        })
    return sorted(records, key=lambda r: r["path"])


def write_outputs(records: list[dict], output_dir: Path, obsidian_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    obsidian_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().isoformat(timespec="seconds")

    (output_dir / "repository_index.json").write_text(json.dumps({"generated_at": timestamp, "files": records}, indent=2), encoding="utf-8")

    md = ["# Repository Index", "", f"Generated: {timestamp}", "", f"Files scanned: {len(records)}", ""]
    for r in records:
        md += [f"## {r['path']}", f"- Type: `{r['extension']}`", f"- Lines: {r['line_count']}", f"- Classes: {', '.join(r['classes']) if r['classes'] else 'None detected'}", f"- Functions/signatures detected: {len(r['functions_or_signatures'])}", ""]
    (output_dir / "repository_index.md").write_text("\n".join(md), encoding="utf-8")

    learning = ["# Codebase Learning Notes", "", "This file is generated as a first-pass learning map. Review and expand it manually or through Codex.", ""]
    for r in records:
        learning += [f"## {r['path']}", "", "Purpose:", "- To be reviewed and explained.", "", "Important items detected:"]
        for c in r["classes"][:10]:
            learning.append(f"- Class: `{c}`")
        for f in r["functions_or_signatures"][:10]:
            learning.append(f"- Function/signature: `{f}`")
        learning.append("")
    (output_dir / "code_learning_notes.md").write_text("\n".join(learning), encoding="utf-8")

    comments = ["# Comment Suggestions Report", "", "Safe mode: no source files were edited.", "", "Recommended rule: add comments that explain WHY the code exists, not only WHAT it does.", ""]
    for r in records:
        comments += [f"## {r['path']}", "Suggested review:", "- Check if public functions/classes have clear docstrings/comments.", "- Add learning comments around complex logic, hardware pins, API routes, state management, and safety logic.", ""]
    (output_dir / "comment_suggestions.md").write_text("\n".join(comments), encoding="utf-8")

    arch = ["# Architecture Map", "", "First-pass architecture view grouped by top-level folder.", ""]
    top = {}
    for r in records:
        root = r["path"].split("/")[0]
        top[root] = top.get(root, 0) + 1
    for folder, count in sorted(top.items()):
        arch.append(f"- `{folder}`: {count} scanned files")
    (output_dir / "architecture_map.md").write_text("\n".join(arch), encoding="utf-8")

    memory = ["# Project Memory", "", f"Generated: {timestamp}", "", "## Current Snapshot", f"- Files scanned: {len(records)}", "", "## Decisions", "- Add important repo decisions here.", "", "## Lessons Learned", "- Add learning notes here over time."]
    (output_dir / "project_memory.md").write_text("\n".join(memory), encoding="utf-8")

    for name in ["repository_index.md", "code_learning_notes.md", "architecture_map.md", "project_memory.md"]:
        (obsidian_dir / name).write_text((output_dir / name).read_text(encoding="utf-8"), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", default="config/engine_config.yaml")
    args = parser.parse_args()
    module_root = Path(__file__).resolve().parents[1]
    cfg = load_config(module_root / args.config)
    repo_root = (module_root / cfg.get("paths", {}).get("repo_root", "..")).resolve()
    output_dir = module_root / cfg.get("paths", {}).get("output_dir", "output")
    obsidian_dir = module_root / cfg.get("paths", {}).get("obsidian_export_dir", "output/obsidian_export")
    records = scan_repo(repo_root, cfg)
    write_outputs(records, output_dir, obsidian_dir)
    print(f"Omega Knowledge Engine scan complete. Files scanned: {len(records)}")
    print(f"Output written to: {output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
