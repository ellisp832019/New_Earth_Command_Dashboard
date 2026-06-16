#!/usr/bin/env python3
"""Create an Omega Standard experiment folder with JSON, markdown templates and evidence folders."""
from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path

FOLDERS = [
    "data",
    "evidence/photos",
    "evidence/videos",
    "evidence/proteus/project_files",
    "evidence/proteus/screenshots",
    "evidence/proteus/waveforms",
    "evidence/kicad",
    "evidence/fusion",
    "evidence/ltspice",
    "evidence/scope",
    "evidence/logic_analyzer",
    "evidence/thermal",
    "evidence/screenshots",
    "exports",
]

TEMPLATES = {
    "00_BRIEF.md": "# {experiment_id} — {title}\n\n## Project\n\n{project}\n\n## Objective\n\n{objective}\n\n## Hypothesis\n\n{hypothesis}\n",
    "01_TEST_PLAN.md": "# Test Plan\n\n## Steps\n\n1. Prepare bench.\n2. Capture evidence.\n3. Run test.\n4. Save data.\n5. Analyse.\n",
    "02_RESULTS.md": "# Results\n\nPending.\n",
    "03_LESSONS_LEARNED.md": "# Lessons Learned\n\nPending.\n",
}


def slug(text: str) -> str:
    return "_".join("".join(ch for ch in text.upper() if ch.isalnum() or ch in " _-").split())


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True, help="Experiments root folder")
    parser.add_argument("--id", required=True, help="Experiment ID, e.g. EXP-0003")
    parser.add_argument("--title", required=True)
    parser.add_argument("--project", required=True)
    parser.add_argument("--category", default="GENERAL")
    parser.add_argument("--objective", default="")
    parser.add_argument("--hypothesis", default="")
    parser.add_argument("--owner", default="Peter Ellis")
    args = parser.parse_args()

    folder = Path(args.root) / f"{args.id}_{slug(args.title)}"
    folder.mkdir(parents=True, exist_ok=True)
    for item in FOLDERS:
        (folder / item).mkdir(parents=True, exist_ok=True)

    record = {
        "experiment_id": args.id,
        "title": args.title,
        "project": args.project,
        "status": "PLANNED",
        "category": args.category,
        "owner": args.owner,
        "created_date": date.today().isoformat(),
        "objective": args.objective,
        "hypothesis": args.hypothesis,
        "software_used": [],
        "hardware_used": [],
        "evidence": [],
        "results_summary": "",
        "conclusion": "",
        "lessons_learned": [],
        "next_actions": []
    }
    (folder / "experiment.json").write_text(json.dumps(record, indent=2), encoding="utf-8")

    for filename, template in TEMPLATES.items():
        (folder / filename).write_text(template.format(**record), encoding="utf-8")

    print(f"Created {folder}")

if __name__ == "__main__":
    main()
