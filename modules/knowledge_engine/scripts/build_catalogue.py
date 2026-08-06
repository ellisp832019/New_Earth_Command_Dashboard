from __future__ import annotations

import csv
import json
from collections import Counter
from pathlib import Path

from common import ensure_dir, load_config, output_paths


def main() -> None:
    config = load_config()
    paths = output_paths(config)
    catalogue_json = paths["catalogue"] / "pdf_catalogue.json"
    catalogue_csv = paths["catalogue"] / "pdf_catalogue.csv"
    stats_json = paths["catalogue"] / "library_stats.json"

    if not catalogue_json.exists():
        raise FileNotFoundError(f"Run scan_library.py first. Missing: {catalogue_json}")

    items = json.loads(catalogue_json.read_text(encoding="utf-8"))
    items.sort(key=lambda item: (item.get("source_section", ""), item.get("relative_path", ""), item.get("title", "")))
    ensure_dir(paths["catalogue"])

    fieldnames = [
        "id", "title", "filename", "relative_path", "source_section", "category",
        "file_size_bytes", "page_count", "text_extractable", "ocr_required",
        "summary_status", "audio_status", "listened_status", "notes_path",
        "extracted_text_path", "audio_manifest_path", "full_path"
    ]

    catalogue_json.write_text(json.dumps(items, indent=2, ensure_ascii=False), encoding="utf-8")

    with catalogue_csv.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        for item in items:
            writer.writerow(item)

    stats = {
        "total_pdfs": len(items),
        "by_source_section": dict(Counter(item.get("source_section", "UNKNOWN") for item in items)),
        "by_category": dict(Counter(item.get("category", "UNKNOWN") for item in items)),
        "text_extractable": sum(1 for item in items if item.get("text_extractable")),
        "ocr_required": sum(1 for item in items if item.get("ocr_required")),
        "audio_generated": sum(1 for item in items if item.get("audio_status") == "generated"),
    }

    stats_json.write_text(json.dumps(stats, indent=2), encoding="utf-8")

    print(f"Wrote {catalogue_json}")
    print(f"Wrote {catalogue_csv}")
    print(f"Wrote {stats_json}")


if __name__ == "__main__":
    main()
