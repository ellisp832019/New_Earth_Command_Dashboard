#!/usr/bin/env python3
"""Create a local Command Deck config file from the bundled example."""
from pathlib import Path
import argparse
import shutil


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", default="config/command_deck.example.json")
    parser.add_argument("--destination", default="config/command_deck.json")
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite the destination if it already exists.",
    )
    args = parser.parse_args()

    source = Path(args.source)
    destination = Path(args.destination)

    if not source.exists():
        raise SystemExit(f"Example config not found: {source}")

    if destination.exists() and not args.force:
        raise SystemExit(
            f"{destination} already exists. Use --force to overwrite it."
        )

    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
    print(destination)


if __name__ == "__main__":
    main()
