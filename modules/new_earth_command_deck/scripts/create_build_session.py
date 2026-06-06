#!/usr/bin/env python3
"""Create a daily build session log."""
from pathlib import Path
from datetime import datetime
import argparse
import json


def load_config(path: Path) -> dict:
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return {}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", default="New Earth Dashboard")
    parser.add_argument("--config", default="config/command_deck.json")
    args = parser.parse_args()
    config = load_config(Path(args.config))
    root = Path(config.get("command_deck_path", "./COMMAND_DECK"))
    date = datetime.now().strftime("%Y-%m-%d")
    folder = root / "08_TEST_LOGS" / date
    folder.mkdir(parents=True, exist_ok=True)
    path = folder / f"{date}_build_session.md"
    if not path.exists():
        path.write_text(f"# Build Session - {args.project}\n\nDate: {date}\n\n## Intention\n\n## Work completed\n\n## Decisions\n\n## Issues\n\n## Next actions\n", encoding="utf-8")
    print(path)

if __name__ == "__main__":
    main()
