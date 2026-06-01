from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

DEFAULT_ROOT = Path("D:/NEW_EARTH_OMEGA_OS_PACK/22_KNOWLEDGE_AND_LEARNING")
MODULE_ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = MODULE_ROOT / "config.json"
CONFIG_EXAMPLE_PATH = MODULE_ROOT / "config.example.json"


def load_config() -> dict[str, Any]:
    path = CONFIG_PATH if CONFIG_PATH.exists() else CONFIG_EXAMPLE_PATH
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def as_path(value: str) -> Path:
    return Path(value).expanduser()


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def iso_from_timestamp(ts: float) -> str:
    return datetime.fromtimestamp(ts).isoformat(timespec="seconds")


def make_item_id(full_path: str) -> str:
    return hashlib.sha256(full_path.lower().encode("utf-8")).hexdigest()[:16]


def safe_slug(text: str) -> str:
    cleaned = "".join(ch if ch.isalnum() else "_" for ch in text).strip("_")
    while "__" in cleaned:
        cleaned = cleaned.replace("__", "_")
    return cleaned[:120] or "untitled"


def sanitize_text(value: str) -> str:
    cleaned = re.sub(r"[\x00-\x1f\x7f]", " ", value)
    return " ".join(cleaned.split())


def silence_mupdf_diagnostics() -> None:
    try:
        import fitz

        fitz.TOOLS.mupdf_display_errors(False)
        fitz.TOOLS.mupdf_display_warnings(False)
    except Exception:
        # Keep the scripts usable even if a PyMuPDF version lacks these hooks.
        pass


def output_paths(config: dict[str, Any]) -> dict[str, Path]:
    return {
        "root": as_path(config["knowledge_learning_root"]),
        "catalogue": as_path(config["library_catalogue_path"]),
        "indexing": as_path(config["ai_indexing_path"]),
        "audio": as_path(config["audio_library_path"]),
        "extracted_text": as_path(config["ai_indexing_path"]) / "extracted_text",
        "chunks": as_path(config["ai_indexing_path"]) / "chunks",
        "search_index": as_path(config["ai_indexing_path"]) / "search_index",
    }
