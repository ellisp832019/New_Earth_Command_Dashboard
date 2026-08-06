#!/usr/bin/env bash
set -euo pipefail
DASHBOARD_ROOT="${1:-.}"
mkdir -p "$DASHBOARD_ROOT/modules"
cp -R "$(dirname "$0")/.." "$DASHBOARD_ROOT/modules/gaia_voice_assistant"
echo "GAIA module copied to $DASHBOARD_ROOT/modules/gaia_voice_assistant"
