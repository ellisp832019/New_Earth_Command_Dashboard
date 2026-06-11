#!/usr/bin/env bash
set -euo pipefail
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python examples/dashboard_mock/mock_dashboard_api.py &
MOCK_PID=$!
python -m src.voice_gateway.app
kill "$MOCK_PID" || true
