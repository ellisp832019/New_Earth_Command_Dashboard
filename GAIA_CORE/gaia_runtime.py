from __future__ import annotations

import json
import os
from pathlib import Path
from typing import Any

def _repo_fallback_root() -> Path:
    return Path(__file__).resolve().parent / ".gaia_usb"


def _resolve_usb_root() -> Path:
    override = os.environ.get("GAIA_USB_ROOT", "").strip()
    if override:
        override_path = Path(override).expanduser()
        if override_path.exists():
            return override_path.resolve()

    if os.name == "nt":
        candidates = (Path("F:/GAIA_USB"), Path("F:/"))
    else:
        candidates = (Path("/mnt/f/GAIA_USB"), Path("/mnt/f"))

    for candidate in candidates:
        if candidate.exists():
            return candidate.resolve()

    return _repo_fallback_root().resolve()


USB_ROOT = _resolve_usb_root()

GAIA_DIR = USB_ROOT
CONFIG_DIR = GAIA_DIR / "04_CONFIG"
MEMORY_DIR = GAIA_DIR / "03_MEMORY"
LOGS_DIR = GAIA_DIR / "05_LOGS"
MODELS_DIR = GAIA_DIR / "02_MODELS" / "ollama_models"
BRIDGE_DIR = GAIA_DIR / "06_DASHBOARD_BRIDGE"

CONFIG_FILE = CONFIG_DIR / "gaia_config.json"
DEFAULT_CONFIG = {
    "assistant_name": "GAIA",
    "assistant_meaning": "Guardian AI Assistant",
    "wake_name": "Gaia",
    "runtime_mode": "portable_usb",
    "dashboard_api_url": "http://localhost:3000",
    "gaia_runtime_url": "http://localhost:8765",
    "ollama_url": "http://localhost:11434",
    "default_model": "qwen2.5:7b",
    "conversation_history_limit": 12,
    "stt_engine": "whisper",
    "tts_engine": "kokoro",
    "permission_mode": "guarded",
    "require_confirmation_for": [
        "finance",
        "file_delete",
        "messaging",
        "microgrow_control",
        "system_settings",
        "publishing"
    ]
}


def ensure_directories() -> None:
    for path in (CONFIG_DIR, MEMORY_DIR, LOGS_DIR, MODELS_DIR, BRIDGE_DIR):
        path.mkdir(parents=True, exist_ok=True)


def load_config() -> dict[str, Any]:
    ensure_directories()
    if not CONFIG_FILE.exists():
        CONFIG_FILE.write_text(json.dumps(DEFAULT_CONFIG, indent=2), encoding="utf-8")
        return DEFAULT_CONFIG.copy()
    try:
        return json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
    except Exception:
        return DEFAULT_CONFIG.copy()


def save_config(config: dict[str, Any]) -> None:
    ensure_directories()
    CONFIG_FILE.write_text(json.dumps(config, indent=2), encoding="utf-8")


def get_ollama_models_path() -> Path:
    ensure_directories()
    return MODELS_DIR


def get_memory_path(filename: str) -> Path:
    ensure_directories()
    return MEMORY_DIR / filename


def get_log_path(filename: str) -> Path:
    ensure_directories()
    return LOGS_DIR / filename
