#!/usr/bin/env python3
"""Create or update an Obsidian experiment note from experiment.json."""
from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--experiment", required=True)
    parser.add_argument("--vault", required=True)
    args = parser.parse_args()

    exp = Path(args.experiment)
    vault = Path(args.vault)
    record = json.loads((exp / "experiment.json").read_text(encoding="utf-8"))
    out_dir = vault / "Experiments" / record["project"]
    out_dir.mkdir(parents=True, exist_ok=True)
    note = out_dir / f"{record['experiment_id']} - {record['title']}.md"
    note.write_text(
        "---\n"
        "type: experiment\n"
        f"experiment_id: {record['experiment_id']}\n"
        f"project: {record['project']}\n"
        f"status: {record['status']}\n"
        f"category: {record['category']}\n"
        "---\n\n"
        f"# {record['experiment_id']} — {record['title']}\n\n"
        f"## Objective\n\n{record['objective']}\n\n"
        f"## Hypothesis\n\n{record['hypothesis']}\n\n"
        f"## Evidence folder\n\n`{exp}`\n",
        encoding="utf-8"
    )
    print(f"Wrote {note}")

if __name__ == "__main__":
    main()
