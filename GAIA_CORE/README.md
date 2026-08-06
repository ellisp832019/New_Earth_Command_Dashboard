# GAIA_CORE

This folder contains the GAIA runtime bridge and local runtime helpers for the New Earth Command Dashboard.

## Starting the GAIA bridge

The bridge exposes a local HTTP runtime used by the dashboard via `modules/gaia_voice_assistant/dashboard_bridge/gaia_bridge.py`.

### Windows PowerShell

```powershell
cd "<repo root>\GAIA_CORE"
.\start_gaia_bridge.ps1
```

### Linux/macOS

```bash
cd "<repo root>/GAIA_CORE"
./start_gaia_bridge.sh
```

## USB-style GAIA layout

The scripts use `GAIA_USB_ROOT` when present. If not set:

- Windows prefers `F:\GAIA_USB`, then `F:\`
- Linux/macOS prefers `/mnt/f/GAIA_USB`, then `/mnt/f`
- If the removable drive is not available, the runtime falls back to a local `.gaia_usb` folder beside `GAIA_CORE`

The runtime will load configuration from:

- `GAIA_USB_ROOT/04_CONFIG/gaia_config.json`
- `GAIA_USB_ROOT/03_MEMORY`
- `GAIA_USB_ROOT/05_LOGS`
- `GAIA_USB_ROOT/02_MODELS/ollama_models`
- `GAIA_USB_ROOT/06_DASHBOARD_BRIDGE`

## Runtime endpoints

- `GET /health`
- `POST /command`
- `POST /conversation`
- `POST /shutdown`

The dashboard bridge expects the runtime at `http://localhost:8765` by default.

## Offline conversation

`POST /conversation` uses the local Ollama-compatible chat endpoint configured in `gaia_config.json`.
The default model is `qwen2.5:7b`, and the runtime will keep a short remembered thread in the local memory folder.
