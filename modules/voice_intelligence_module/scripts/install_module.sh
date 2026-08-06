#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-./modules/voice_intelligence}"
mkdir -p "$TARGET"
cp -R docs src examples tests "$TARGET"/
echo "Voice Intelligence module copied to $TARGET"
