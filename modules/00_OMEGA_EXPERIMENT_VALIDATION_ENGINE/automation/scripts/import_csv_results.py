#!/usr/bin/env python3
"""Import a CSV into an experiment data folder and create a simple markdown summary."""
from __future__ import annotations

import argparse
import csv
import shutil
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--experiment", required=True, help="Experiment folder")
    parser.add_argument("--csv", required=True, help="CSV file to import")
    args = parser.parse_args()

    exp = Path(args.experiment)
    csv_path = Path(args.csv)
    data_dir = exp / "data"
    data_dir.mkdir(exist_ok=True)
    dest = data_dir / csv_path.name
    shutil.copy2(csv_path, dest)

    with dest.open(newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    summary = exp / "exports" / f"{csv_path.stem}_summary.md"
    summary.parent.mkdir(exist_ok=True)
    columns = rows[0].keys() if rows else []
    summary.write_text(
        "# CSV Import Summary\n\n"
        f"File: `{dest}`\n\n"
        f"Rows: {len(rows)}\n\n"
        f"Columns: {', '.join(columns)}\n",
        encoding="utf-8"
    )
    print(f"Imported {dest}")

if __name__ == "__main__":
    main()
