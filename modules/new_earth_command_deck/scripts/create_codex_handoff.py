#!/usr/bin/env python3
"""Create a Codex handoff markdown file."""
from pathlib import Path
from datetime import datetime
import argparse
import json
import re


def slugify(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_") or "handoff"


def load_config(path: Path) -> dict:
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8"))
    return {}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--title", default="Command Deck Task")
    parser.add_argument("--project", default="New Earth Dashboard")
    parser.add_argument("--config", default="config/command_deck.json")
    args = parser.parse_args()
    config = load_config(Path(args.config))
    root = Path(config.get("command_deck_path", "./COMMAND_DECK")) / "06_AI_AGENT_HANDOFFS"
    root.mkdir(parents=True, exist_ok=True)
    date = datetime.now().strftime("%Y-%m-%d")
    path = root / f"{date}_{slugify(args.title)}.md"
    path.write_text(f"# Codex Handoff: {args.title}\n\nProject: {args.project}\nDate: {date}\n\n## Goal\n\n## Current context\n\n## Files to inspect\n\n## Tasks\n\n## Constraints\n\n## Acceptance criteria\n", encoding="utf-8")
    print(path)

if __name__ == "__main__":
    main()
