#!/usr/bin/env python3
"""Generate a GitHub issue body markdown file for manual paste or GitHub CLI use."""
from __future__ import annotations

import argparse
import json
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--experiment", required=True)
    args = parser.parse_args()
    exp = Path(args.experiment)
    record = json.loads((exp / "experiment.json").read_text(encoding="utf-8"))
    issue = exp / "exports" / f"{record['experiment_id']}_github_issue.md"
    issue.parent.mkdir(exist_ok=True)
    issue.write_text(
        f"# {record['experiment_id']} — {record['title']}\n\n"
        f"## Project\n{record['project']}\n\n"
        f"## Objective\n{record['objective']}\n\n"
        f"## Hypothesis\n{record['hypothesis']}\n\n"
        "## Checklist\n"
        "- [ ] Create test plan\n- [ ] Capture evidence\n- [ ] Import data\n- [ ] Analyse result\n- [ ] Write lessons learned\n\n"
        f"## Evidence folder\n`{exp}`\n",
        encoding="utf-8"
    )
    print(f"Wrote {issue}")

if __name__ == "__main__":
    main()
