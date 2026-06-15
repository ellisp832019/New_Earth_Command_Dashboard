#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/sync_obsidian.py"

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "Python is required to run the Obsidian sync module."
  exit 1
fi

if [[ "${1:-}" == "watch" || "${1:-}" == "--watch" ]]; then
  shift || true
  exec "$PYTHON_BIN" "$PYTHON_SCRIPT" watch "$@"
fi

exec "$PYTHON_BIN" "$PYTHON_SCRIPT" sync "$@"
