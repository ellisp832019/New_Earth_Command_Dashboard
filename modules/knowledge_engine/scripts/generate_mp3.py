"""
Placeholder MP3 generator.

This file prepares the structure for the audio engine but does not call any paid/cloud TTS by default.

Recommended later options:
- Offline/local: Piper TTS
- Cloud/premium: OpenAI TTS, ElevenLabs, Azure Speech

Design rule:
Original PDFs stay untouched. Generated audio goes into Omega OS / 11_AUDIO_LIBRARY.
"""
from __future__ import annotations

import json
from pathlib import Path

from common import ensure_dir, load_config, output_paths


def main() -> None:
    config = load_config()
    paths = output_paths(config)
    catalogue_path = paths["catalogue"] / "pdf_catalogue.json"

    if not catalogue_path.exists():
        raise FileNotFoundError(f"Run scan_library.py first. Missing: {catalogue_path}")

    items = json.loads(catalogue_path.read_text(encoding="utf-8"))
    prepared = 0

    for item in items:
        manifest_path = Path(item["audio_manifest_path"])
        ensure_dir(manifest_path.parent)
        if not manifest_path.exists():
            manifest = {
                "item_id": item["id"],
                "title": item["title"],
                "source_pdf": item["full_path"],
                "status": "not_started",
                "chapters": [],
                "tts_engine": None,
                "listened_progress_seconds": 0
            }
            manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
            prepared += 1

    print(f"Prepared audio manifests: {prepared}")
    print("MP3 generation engine is ready for a TTS backend.")


if __name__ == "__main__":
    main()
