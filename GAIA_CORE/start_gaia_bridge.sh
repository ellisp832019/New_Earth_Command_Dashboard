#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -x "./.venv/bin/python" ]; then
  python3 -m venv .venv
fi

PYTHON_EXE="./.venv/bin/python"
if [ ! -x "$PYTHON_EXE" ]; then
  echo "Could not find a Python executable in .venv." >&2
  exit 1
fi

if [ -z "${GAIA_USB_ROOT:-}" ]; then
  if [ -d "/mnt/f/GAIA_USB" ]; then
    export GAIA_USB_ROOT="/mnt/f/GAIA_USB"
  elif [ -d "/mnt/f" ]; then
    export GAIA_USB_ROOT="/mnt/f"
  else
    export GAIA_USB_ROOT="$SCRIPT_DIR/.gaia_usb"
  fi
fi

echo "Starting GAIA bridge server with GAIA_USB_ROOT=$GAIA_USB_ROOT"
"$PYTHON_EXE" gaia_bridge_server.py
