#!/usr/bin/env python3
"""Validate command registry JSON."""
import json
from pathlib import Path
import sys

path = Path(sys.argv[1] if len(sys.argv) > 1 else "config/command_registry.example.json")
data = json.loads(path.read_text(encoding="utf-8"))
ids = set()
for command in data.get("commands", []):
    for key in ["id", "label", "type"]:
        if key not in command:
            raise SystemExit(f"Missing {key} in {command}")
    if command["id"] in ids:
        raise SystemExit(f"Duplicate command id: {command['id']}")
    ids.add(command["id"])
print(f"OK: {len(ids)} commands validated")
