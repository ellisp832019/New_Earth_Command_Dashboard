#!/usr/bin/env python3
"""Create a New Earth meeting folder with standard markdown files."""
from pathlib import Path
from datetime import datetime
import argparse
import json
import re


def slugify(text: str) -> str:
    text = text.strip().lower()
    text = re.sub(r"[^a-z0-9]+", "_", text)
    return text.strip("_") or "untitled_meeting"


def load_config(config_path: Path) -> dict:
    if config_path.exists():
        return json.loads(config_path.read_text(encoding="utf-8"))
    return {}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--title", default="New Earth Meeting")
    parser.add_argument("--project", default="General")
    parser.add_argument("--config", default="config/command_deck.json")
    args = parser.parse_args()

    config = load_config(Path(args.config))
    base = Path(config.get("meetings_path", "./MEETINGS"))
    today = datetime.now().strftime("%Y-%m-%d")
    year = datetime.now().strftime("%Y")
    folder = base / year / f"{today}_{slugify(args.title)}"
    (folder / "05_ATTACHMENTS").mkdir(parents=True, exist_ok=True)
    (folder / "06_RECORDINGS").mkdir(parents=True, exist_ok=True)
    (folder / "99_EXPORTS").mkdir(parents=True, exist_ok=True)

    files = {
        "00_MEETING_NOTE.md": f"# {args.title}\n\nDate: {today}\nProject: {args.project}\nAttendees:\n\n## Purpose\n\n## Notes\n\n## Outcome\n",
        "01_TRANSCRIPT.md": f"# Transcript - {args.title}\n\nPaste transcript here.\n",
        "02_SUMMARY.md": f"# Summary - {args.title}\n\n## Key points\n\n## Follow-up\n",
        "03_ACTIONS.md": "# Actions\n\n| Action | Owner | Due | Status |\n|---|---|---|---|\n",
        "04_DECISIONS.md": "# Decisions\n\n| Decision | Reason | Date | Linked Project |\n|---|---|---|---|\n",
    }
    for name, content in files.items():
        p = folder / name
        if not p.exists():
            p.write_text(content, encoding="utf-8")

    print(folder)


if __name__ == "__main__":
    main()
