#!/usr/bin/env bash
set -euo pipefail

GATEWAY_URL="${GATEWAY_URL:-http://127.0.0.1:8088/voice/command}"
GATEWAY_SECRET="${NEW_EARTH_VOICE_GATEWAY_SECRET:-}"
SECRET_HEADER=()

if [[ -n "$GATEWAY_SECRET" ]]; then
  SECRET_HEADER=(-H "x-gateway-secret: $GATEWAY_SECRET")
fi

echo "Testing dashboard summary..."
curl -s -X POST "$GATEWAY_URL" \
  -H 'Content-Type: application/json' \
  "${SECRET_HEADER[@]}" \
  -d '{"source":"local-test","intent":"GetTodaySummaryIntent","command":"dashboard.summary.today","slots":{}}' | python -m json.tool

echo "Testing project status..."
curl -s -X POST "$GATEWAY_URL" \
  -H 'Content-Type: application/json' \
  "${SECRET_HEADER[@]}" \
  -d '{"source":"local-test","intent":"GetProjectStatusIntent","command":"dashboard.project.status.read","slots":{}}' | python -m json.tool

echo "Testing MicroGrow status..."
curl -s -X POST "$GATEWAY_URL" \
  -H 'Content-Type: application/json' \
  "${SECRET_HEADER[@]}" \
  -d '{"source":"local-test","intent":"GetMicroGrowStatusIntent","command":"microgrow.status.read","slots":{}}' | python -m json.tool

echo "Testing blocked command..."
curl -s -X POST "$GATEWAY_URL" \
  -H 'Content-Type: application/json' \
  "${SECRET_HEADER[@]}" \
  -d '{"source":"local-test","intent":"DeleteFileIntent","command":"filesystem.delete","slots":{"path":"D:/NEW_EARTH_OMEGA_OS_PACK"}}' | python -m json.tool
