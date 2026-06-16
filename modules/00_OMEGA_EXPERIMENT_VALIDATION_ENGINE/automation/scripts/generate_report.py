#!/usr/bin/env python3
"""Generate a simple Omega markdown report from experiment.json and markdown sections."""
from __future__ import annotations

import argparse
import json
from pathlib import Path


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8") if path.exists() else ""


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--experiment", required=True)
    args = parser.parse_args()
    exp = Path(args.experiment)
    record = json.loads((exp / "experiment.json").read_text(encoding="utf-8"))
    report = exp / "exports" / f"{record['experiment_id']}_OMEGA_REPORT.md"
    report.parent.mkdir(exist_ok=True)
    report.write_text(
        f"# {record['experiment_id']} — {record['title']}\n\n"
        f"Project: {record['project']}\n\n"
        f"Status: {record['status']}\n\n"
        "---\n\n"
        + read(exp / "00_BRIEF.md") + "\n\n"
        + read(exp / "01_TEST_PLAN.md") + "\n\n"
        + read(exp / "02_RESULTS.md") + "\n\n"
        + read(exp / "03_LESSONS_LEARNED.md"),
        encoding="utf-8"
    )
    print(f"Generated {report}")

if __name__ == "__main__":
    main()
