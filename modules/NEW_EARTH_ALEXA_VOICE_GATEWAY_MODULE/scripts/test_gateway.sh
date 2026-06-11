#!/usr/bin/env bash
set -euo pipefail

GATEWAY_URL="${GATEWAY_URL:-http://127.0.0.1:8088/voice/command}"

echo "Testing dashboard summary..."
curl -s -X POST "$GATEWAY_URL" \
  -H 'Content-Type: application/json' \
  -d '{"source":"local-test","intent":"GetTodaySummaryIntent","command":"dashboard.summary.today","slots":{}}' | python -m json.tool

echo "Testing project status..."
curl -s -X POST "$GATEWAY_URL" \
  -H 'Content-Type: application/json' \
  -d '{"source":"local-test","intent":"GetProjectStatusIntent","command":"dashboard.project.status.read","slots":{}}' | python -m json.tool

echo "Testing MicroGrow status..."
curl -s -X POST "$GATEWAY_URL" \
  -H 'Content-Type: application/json' \
  -d '{"source":"local-test","intent":"GetMicroGrowStatusIntent","command":"microgrow.status.read","slots":{}}' | python -m json.tool

echo "Testing blocked command..."
curl -s -X POST "$GATEWAY_URL" \
  -H 'Content-Type: application/json' \
  -d '{"source":"local-test","intent":"DeleteFileIntent","command":"filesystem.delete","slots":{"path":"D:/NEW_EARTH_OMEGA_OS_PACK"}}' | python -m json.tool
